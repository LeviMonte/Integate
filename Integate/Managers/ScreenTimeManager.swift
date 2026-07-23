//
//  ScreenTimeManager.swift
//  Integate
//
//  Real FamilyControls implementation.
//  Shields selected apps via ManagedSettingsStore — no honor system needed.
//  When a shielded app is tapped, the custom shield appears (ShieldConfigurationExtension)
//  and the user taps "Open Integate →" which signals via App Group UserDefaults.
//  On launch Integate detects that signal and prompts the user to solve.
//
//  REQUIRES in Xcode (main target):
//    Signing & Capabilities → + Capability → Family Controls
//    Signing & Capabilities → + Capability → App Groups  →  group.com.monte.integate
//    (use YOUR actual bundle ID prefix — just keep "group." at the front)
//
//  ── Two timer modes ──────────────────────────────────────────────────
//  Earned time can run out in one of two ways, controlled by `activeUseOnlyMode`:
//
//  • Continuous (default, activeUseOnlyMode == false): the clock starts the
//    instant a problem is solved and counts down in real wall-clock time,
//    whether or not the user is actually in a blocked app. This is the
//    simple, predictable behavior the app shipped with.
//
//  • Active-use only (activeUseOnlyMode == true): the earned time is a
//    *budget* that only depletes while the user is actually using one of
//    the blocked apps/categories. This is implemented with a
//    DeviceActivityEvent usage threshold (not a local Timer) — iOS itself
//    tracks foreground usage of the selected apps and fires
//    DeviceActivityMonitorExtension.eventDidReachThreshold once cumulative
//    usage hits the budget, even if Integate isn't running.
//
//  Both modes lean on DeviceActivityCenter (in addition to the in-app Timer)
//  so re-locking still happens if the app is backgrounded or killed — that
//  in-process Timer alone was never reliable for that (see: "doesn't kick me
//  off the app when time runs out").
//

import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine
import UserNotifications
import UIKit

class ScreenTimeManager: ObservableObject {

    // MARK: - Published State

    @Published var isAuthorized:     Bool = false
    @Published var activitySelection: FamilyActivitySelection = FamilyActivitySelection() {
        didSet {
            saveSelection()
            if !isUnlocked { applyRestrictions() }
        }
    }
    @Published var timeRemainingSeconds: Int  = 0
    @Published var unlockExpiryDate:    Date? = nil
    @Published var isUnlocked:          Bool  = false

    /// True only for the remainder of the app session that follows tapping
    /// "Open Integate →" on a shield. Must NOT leak into later, unrelated
    /// app opens — see checkPendingUnlockSignal().
    @Published var pendingUnlockActive: Bool = false

    /// User-facing setting: OFF = classic wall-clock countdown from the moment
    /// you solve. ON = time only depletes while you're actually using a
    /// blocked app/category.
    @Published var activeUseOnlyMode: Bool {
        didSet {
            UserDefaults.standard.set(activeUseOnlyMode, forKey: Keys.activeUseOnlyMode)
        }
    }

    // MARK: - Private

    private let store = ManagedSettingsStore()
    private let deviceActivityCenter = DeviceActivityCenter()

    /// ⚠️ Change this to match your actual Bundle ID prefix
    let appGroupID = "group.com.monte.integate"

    private var sharedDefaults: UserDefaults? { UserDefaults(suiteName: appGroupID) }
    private var countdownTimer: Timer?
    private let notificationCenter = UNUserNotificationCenter.current()

    // MARK: - Keys

    enum Keys {
        static let selection         = "mg_activitySelection"
        static let unlockExpiry      = "mg_unlockExpiry"
        static let pendingUnlock     = "mg_pendingUnlock"        // written by ShieldActionExtension
        static let timeCap           = "mg_timeCap"
        static let activeUseOnlyMode = "mg_activeUseOnlyMode"
        static let activeUseInProgress   = "mg_activeUseInProgress"
        static let activeUseBudgetSeconds = "mg_activeUseBudgetSeconds"
        /// Shared (app-group) flag — written by DeviceActivityMonitorExtension
        /// when an active-use budget is fully consumed.
        static let activeUseExpiredFlag = "mg_activeUseExpired"
    }

    // MARK: - DeviceActivity Names

    private enum Activity {
        static let continuous = DeviceActivityName("mg_earnedTime")        // wall-clock safety net
        static let activeUse  = DeviceActivityName("mg_earnedTime_active") // usage-threshold budget
    }
    private enum EventName {
        static let usageThreshold = DeviceActivityEvent.Name("mg_usageThreshold")
    }

    // MARK: - Init

    init() {
        activeUseOnlyMode = UserDefaults.standard.bool(forKey: Keys.activeUseOnlyMode)
        loadSelection()
        refreshAuthorizationStatus()
        resumeIfNeeded()
        checkPendingUnlockSignal()
        requestNotificationPermission()
        observeForeground()
        recheckAuthorizationAfterLaunch()
    }

    // MARK: - Authorization

    func refreshAuthorizationStatus() {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }

    /// AuthorizationCenter's status can briefly read stale/`.notDetermined`
    /// immediately after a cold launch, before FamilyControls has finished
    /// syncing the real (already-approved) state from disk. A single read in
    /// init() can catch that stale value, which then makes `applyRestrictions()`
    /// silently no-op (guard isAuthorized) — shields never get re-applied, and
    /// the picker prompts for permission again even though Settings already
    /// shows it granted. This re-checks shortly after launch and reapplies if
    /// the status flips true.
    ///
    /// Note: if authorization is genuinely revoked — which can legitimately
    /// happen during active Xcode development, since re-signing/reinstalling
    /// the app with a new provisioning profile can invalidate a prior grant —
    /// this won't paper over that; the user will still need to re-grant once.
    /// That's expected, not a bug, and should stop happening once the app is
    /// installed from TestFlight/App Store with stable signing.
    private func recheckAuthorizationAfterLaunch() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)
            let wasAuthorized = isAuthorized
            refreshAuthorizationStatus()
            if isAuthorized && !wasAuthorized {
                applyIfSelectionExists()
            }
        }
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            await MainActor.run {
                self.isAuthorized = true
                self.applyRestrictions()
            }
        } catch {
            await MainActor.run { self.isAuthorized = false }
        }
    }

    // MARK: - Apply / Remove Restrictions

    func applyRestrictions() {
        guard isAuthorized else { return }
        let apps = activitySelection.applicationTokens
        let cats = activitySelection.categoryTokens
        store.shield.applications          = apps.isEmpty ? nil : apps
        store.shield.applicationCategories = cats.isEmpty ? nil : .specific(cats)
    }

    func removeRestrictions() {
        store.clearAllSettings()
    }

    // MARK: - Grant Time (call on successful problem solve)

    var maxSeconds: Int {
        let saved = UserDefaults.standard.integer(forKey: Keys.timeCap)
        return (saved > 0 ? saved : 15) * 60
    }

    func grantTime(seconds: Int) {
        removeRestrictions()   // lift shields immediately
        clearPendingUnlockRequest()

        if activeUseOnlyMode {
            grantActiveUseTime(seconds: seconds)
        } else {
            grantContinuousTime(seconds: seconds)
        }
    }

    private func grantContinuousTime(seconds: Int) {
        let currentRemaining = max(0, Int(unlockExpiryDate?.timeIntervalSinceNow ?? 0))
        let newTotal         = min(currentRemaining + seconds, maxSeconds)
        let expiry           = Date().addingTimeInterval(TimeInterval(newTotal))

        unlockExpiryDate     = expiry
        timeRemainingSeconds = newTotal
        isUnlocked           = true

        UserDefaults.standard.set(expiry, forKey: Keys.unlockExpiry)
        scheduleExpiryNotification(in: newTotal)
        startCountdown(until: expiry)
        startWallClockMonitoring(until: expiry)
    }

    private func grantActiveUseTime(seconds: Int) {
        let currentBudget = UserDefaults.standard.integer(forKey: Keys.activeUseBudgetSeconds)
        let newTotal      = min(currentBudget + seconds, maxSeconds)

        cancelCountdownTimer()   // no local ticking clock in this mode
        unlockExpiryDate     = nil
        timeRemainingSeconds = newTotal
        isUnlocked            = true

        UserDefaults.standard.set(newTotal, forKey: Keys.activeUseBudgetSeconds)
        UserDefaults.standard.set(true, forKey: Keys.activeUseInProgress)
        sharedDefaults?.removeObject(forKey: Keys.activeUseExpiredFlag)

        startActiveUseMonitoring(budgetSeconds: newTotal)
        // No local notification is scheduled here — we don't know the real
        // expiry time in advance. The extension posts its own notification
        // when the usage threshold is actually reached.
    }

    func revokeTimeNow() {
        onExpired()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["mg_timeExpired"])
    }

    // MARK: - Pending Unlock (signalled by ShieldActionExtension)

    /// Reads the one-shot signal ShieldActionExtension writes when "Open
    /// Integate →" is tapped on a shield, and immediately consumes
    /// (clears) the persisted flag.
    ///
    /// This used to be a plain computed property read directly off
    /// UserDefaults, which meant the "App locked — solve to unlock" banner
    /// kept showing on *every* future app open — even ones completely
    /// unrelated to a shield tap — because nothing ever cleared the flag
    /// except actually solving. Now the persisted flag is consumed the
    /// moment it's observed, and `pendingUnlockActive` (in-memory only)
    /// carries it for the rest of *this* session.
    private func checkPendingUnlockSignal() {
        guard sharedDefaults?.bool(forKey: Keys.pendingUnlock) == true else { return }
        pendingUnlockActive = true
        sharedDefaults?.removeObject(forKey: Keys.pendingUnlock)
    }

    func clearPendingUnlockRequest() {
        pendingUnlockActive = false
        sharedDefaults?.removeObject(forKey: Keys.pendingUnlock)
    }

    // MARK: - Countdown (continuous mode only)

    private func startCountdown(until expiry: Date) {
        cancelCountdownTimer()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            let remaining = max(0, Int(expiry.timeIntervalSinceNow))
            DispatchQueue.main.async {
                self.timeRemainingSeconds = remaining
                if remaining == 0 { self.onExpired() }
            }
        }
    }

    private func onExpired() {
        cancelCountdownTimer()
        stopAllMonitoring()
        unlockExpiryDate     = nil
        timeRemainingSeconds = 0
        isUnlocked            = false
        UserDefaults.standard.removeObject(forKey: Keys.unlockExpiry)
        clearActiveUseState()
        applyRestrictions()
    }

    private func cancelCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    // MARK: - DeviceActivity Monitoring

    /// Continuous mode's safety net: schedules a DeviceActivity interval ending
    /// exactly at `expiry`, so DeviceActivityMonitorExtension.intervalDidEnd
    /// re-applies shields even if Integate is backgrounded or terminated.
    ///
    /// ⚠️ DeviceActivitySchedule only understands time-of-day components, not
    /// absolute dates. If `expiry` crosses midnight, this specific window
    /// won't fire correctly — a rare edge case for sessions started in the
    /// last few minutes before midnight.
    private func startWallClockMonitoring(until expiry: Date) {
        deviceActivityCenter.stopMonitoring([Activity.continuous])

        let cal   = Calendar.current
        let start = cal.dateComponents([.hour, .minute, .second], from: Date())
        let end   = cal.dateComponents([.hour, .minute, .second], from: expiry)
        let schedule = DeviceActivitySchedule(intervalStart: start, intervalEnd: end, repeats: false)

        do {
            try deviceActivityCenter.startMonitoring(Activity.continuous, during: schedule)
        } catch {
            print("⚠️ Failed to start wall-clock DeviceActivity monitoring: \(error)")
        }
    }

    /// Active-use mode: monitors real usage of the selected apps/categories
    /// and fires when cumulative usage hits `budgetSeconds`.
    private func startActiveUseMonitoring(budgetSeconds: Int) {
        deviceActivityCenter.stopMonitoring([Activity.activeUse])

        let apps = activitySelection.applicationTokens
        let cats = activitySelection.categoryTokens
        guard !apps.isEmpty || !cats.isEmpty else { return }

        let event = DeviceActivityEvent(
            applications: apps,
            categories: cats,
            threshold: DateComponents(second: budgetSeconds)
        )

        // Covers "now until end of today." A new grant restarts this monitor
        // with the updated cumulative budget, so this only needs to reach
        // midnight — crossing midnight with a still-active budget is a rare
        // edge case (same limitation as the continuous-mode schedule above).
        let cal   = Calendar.current
        let start = cal.dateComponents([.hour, .minute, .second], from: Date())
        let end   = DateComponents(hour: 23, minute: 59, second: 59)
        let schedule = DeviceActivitySchedule(intervalStart: start, intervalEnd: end, repeats: false)

        do {
            try deviceActivityCenter.startMonitoring(
                Activity.activeUse,
                during: schedule,
                events: [EventName.usageThreshold: event]
            )
        } catch {
            print("⚠️ Failed to start active-use DeviceActivity monitoring: \(error)")
        }
    }

    private func stopAllMonitoring() {
        deviceActivityCenter.stopMonitoring([Activity.continuous, Activity.activeUse])
    }

    private func clearActiveUseState() {
        UserDefaults.standard.removeObject(forKey: Keys.activeUseInProgress)
        UserDefaults.standard.removeObject(forKey: Keys.activeUseBudgetSeconds)
        sharedDefaults?.removeObject(forKey: Keys.activeUseExpiredFlag)
    }

    // MARK: - Resume on Launch

    private func resumeIfNeeded() {
        if activeUseOnlyMode {
            resumeActiveUseIfNeeded()
        } else {
            resumeContinuousIfNeeded()
        }
    }

    private func resumeContinuousIfNeeded() {
        if let expiry = UserDefaults.standard.object(forKey: Keys.unlockExpiry) as? Date, expiry > Date() {
            removeRestrictions()
            unlockExpiryDate     = expiry
            timeRemainingSeconds = max(0, Int(expiry.timeIntervalSinceNow))
            isUnlocked            = true
            startCountdown(until: expiry)
        } else {
            UserDefaults.standard.removeObject(forKey: Keys.unlockExpiry)
            applyIfSelectionExists()
        }
    }

    private func resumeActiveUseIfNeeded() {
        let inProgress = UserDefaults.standard.bool(forKey: Keys.activeUseInProgress)
        let expired     = sharedDefaults?.bool(forKey: Keys.activeUseExpiredFlag) ?? false

        if inProgress, !expired {
            removeRestrictions()
            timeRemainingSeconds = UserDefaults.standard.integer(forKey: Keys.activeUseBudgetSeconds)
            unlockExpiryDate      = nil
            isUnlocked             = true
        } else {
            clearActiveUseState()
            applyIfSelectionExists()
        }
    }

    private func applyIfSelectionExists() {
        // Only apply if we actually have apps selected — avoids clearing and
        // re-setting the store with an empty selection on every launch.
        if !activitySelection.applicationTokens.isEmpty || !activitySelection.categoryTokens.isEmpty {
            applyRestrictions()
        }
    }

    // MARK: - Foreground Sync

    /// The extension can re-lock apps (and flag active-use expiry) while
    /// Integate is backgrounded. Re-check state whenever the app comes back
    /// to the foreground so the UI doesn't show a stale "unlocked" state.
    private func observeForeground() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.syncStateFromExtension()
            self?.checkPendingUnlockSignal()
        }
    }

    func syncStateFromExtension() {
        refreshAuthorizationStatus()
        guard isUnlocked else { return }

        if activeUseOnlyMode {
            if sharedDefaults?.bool(forKey: Keys.activeUseExpiredFlag) == true {
                onExpired()
            }
        } else if let expiry = unlockExpiryDate, expiry <= Date() {
            onExpired()
        }
    }

    // MARK: - Persist FamilyActivitySelection

    private func saveSelection() {
        guard let data = try? JSONEncoder().encode(activitySelection) else { return }
        UserDefaults.standard.set(data, forKey: Keys.selection)
        sharedDefaults?.set(data, forKey: Keys.selection)
    }

    private func loadSelection() {
        let data = UserDefaults.standard.data(forKey: Keys.selection)
            ?? sharedDefaults?.data(forKey: Keys.selection)
        if let data, let sel = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            activitySelection = sel
        }
    }

    // MARK: - Formatted Time

    var formattedTimeRemaining: String {
        let m = timeRemainingSeconds / 60
        let s = timeRemainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    // MARK: - Notifications

    private func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func scheduleExpiryNotification(in seconds: Int) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["mg_timeExpired"])
        let content   = UNMutableNotificationContent()
        content.title = "Time's up! 🔒"
        content.body  = "Your earned screen time expired. Open the app to solve another problem."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request  = UNNotificationRequest(identifier: "mg_timeExpired", content: content, trigger: trigger)
        notificationCenter.add(request)
    }
}
