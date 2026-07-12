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
//    Signing & Capabilities → + Capability → App Groups  →  group.com.levimonte.integate
//    (use YOUR actual bundle ID prefix — just keep "group." at the front)
//

import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine
import UserNotifications

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

    // MARK: - Private

    private let store = ManagedSettingsStore()

    /// ⚠️ Change this to match your actual Bundle ID prefix
    let appGroupID = "group.com.levimonte.integate"

    private var sharedDefaults: UserDefaults? { UserDefaults(suiteName: appGroupID) }
    private var countdownTimer: Timer?
    private let notificationCenter = UNUserNotificationCenter.current()

    // MARK: - Keys

    enum Keys {
        static let selection     = "mg_activitySelection"
        static let unlockExpiry  = "mg_unlockExpiry"
        static let pendingUnlock = "mg_pendingUnlock"   // written by ShieldActionExtension
        static let timeCap       = "mg_timeCap"
    }

    // MARK: - Init

    init() {
        loadSelection()
        refreshAuthorizationStatus()
        resumeIfNeeded()
        requestNotificationPermission()
    }

    // MARK: - Authorization

    func refreshAuthorizationStatus() {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
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

        let currentRemaining = max(0, Int(unlockExpiryDate?.timeIntervalSinceNow ?? 0))
        let newTotal         = min(currentRemaining + seconds, maxSeconds)
        let expiry           = Date().addingTimeInterval(TimeInterval(newTotal))

        unlockExpiryDate     = expiry
        timeRemainingSeconds = newTotal
        isUnlocked           = true

        UserDefaults.standard.set(expiry, forKey: Keys.unlockExpiry)
        scheduleExpiryNotification(in: newTotal)
        startCountdown(until: expiry)
        clearPendingUnlockRequest()
    }

    func revokeTimeNow() {
        cancelAll()
        applyRestrictions()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["mg_timeExpired"])
    }

    // MARK: - Pending Unlock (signalled by ShieldActionExtension)

    /// True when the shield's "Open Integate" button was tapped.
    var hasPendingUnlockRequest: Bool {
        sharedDefaults?.bool(forKey: Keys.pendingUnlock) ?? false
    }

    func clearPendingUnlockRequest() {
        sharedDefaults?.removeObject(forKey: Keys.pendingUnlock)
    }

    // MARK: - Countdown

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
        cancelAll()
        UserDefaults.standard.removeObject(forKey: Keys.unlockExpiry)
        applyRestrictions()
    }

    private func cancelAll() {
        cancelCountdownTimer()
        unlockExpiryDate     = nil
        timeRemainingSeconds = 0
        isUnlocked           = false
    }

    private func cancelCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    // MARK: - Resume on Launch

    private func resumeIfNeeded() {
        if let expiry = UserDefaults.standard.object(forKey: Keys.unlockExpiry) as? Date, expiry > Date() {
            removeRestrictions()
            unlockExpiryDate     = expiry
            timeRemainingSeconds = max(0, Int(expiry.timeIntervalSinceNow))
            isUnlocked           = true
            startCountdown(until: expiry)
        } else {
            UserDefaults.standard.removeObject(forKey: Keys.unlockExpiry)
            applyRestrictions()
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
