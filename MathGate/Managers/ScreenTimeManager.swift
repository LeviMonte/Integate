import Foundation
import Combine
import UserNotifications

// MARK: - ScreenTimeManager (Honor System)
//
// This version has NO FamilyControls dependency — no special entitlement needed.
// It tracks earned time and fires a local notification when it expires.
// The actual app-blocking is on you: apps you list here are just a reminder.
//
// When your FamilyControls entitlement is approved, swap this file out for the
// full version (ScreenTimeManager+FamilyControls.swift) — nothing else changes.

class ScreenTimeManager: ObservableObject {

    // MARK: - Published State

    @Published var timeRemainingSeconds: Int = 0
    @Published var unlockExpiryDate: Date? = nil
    @Published var isUnlocked: Bool = false

    /// Apps the user has committed to not opening without solving a problem first.
    @Published var blockedAppNames: [String] {
        didSet { UserDefaults.standard.set(blockedAppNames, forKey: Keys.blockedAppNames) }
    }

    // MARK: - Private

    private var countdownTimer: Timer?
    private let notificationCenter = UNUserNotificationCenter.current()

    // MARK: - Init

    init() {
        blockedAppNames = UserDefaults.standard.stringArray(forKey: Keys.blockedAppNames) ?? []
        requestNotificationPermission()
        resumeIfNeeded()
    }

    // MARK: - Grant Time

    /// Maximum accumulation cap in seconds. Reads the user-chosen cap from UserDefaults.
    var maxSeconds: Int {
        let saved = UserDefaults.standard.integer(forKey: Keys.timeCap)
        return (saved > 0 ? saved : 15) * 60
    }

    /// Call after a problem is solved. ADDS to existing time, capped at the user's cap.
    func grantTime(seconds: Int) {
        let currentRemaining = max(0, Int(unlockExpiryDate?.timeIntervalSinceNow ?? 0))
        let newTotal = min(currentRemaining + seconds, maxSeconds)
        let expiry = Date().addingTimeInterval(TimeInterval(newTotal))

        unlockExpiryDate = expiry
        timeRemainingSeconds = newTotal
        isUnlocked = true

        UserDefaults.standard.set(expiry, forKey: Keys.unlockExpiry)

        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotifID.expiry])
        scheduleExpiryNotification(in: newTotal)
        startCountdown(until: expiry)
    }

    /// Manually end the unlock window early.
    func revokeTimeNow() {
        cancelAll()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotifID.expiry])
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
    }

    private func cancelAll() {
        cancelCountdownTimer()
        unlockExpiryDate = nil
        timeRemainingSeconds = 0
        isUnlocked = false
    }

    private func cancelCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    // MARK: - Resume on Launch

    private func resumeIfNeeded() {
        guard let expiry = UserDefaults.standard.object(forKey: Keys.unlockExpiry) as? Date else { return }
        if expiry > Date() {
            unlockExpiryDate = expiry
            timeRemainingSeconds = max(0, Int(expiry.timeIntervalSinceNow))
            isUnlocked = true
            startCountdown(until: expiry)
        } else {
            UserDefaults.standard.removeObject(forKey: Keys.unlockExpiry)
        }
    }

    // MARK: - Local Notifications

    private func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func scheduleExpiryNotification(in seconds: Int) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [NotifID.expiry])

        let content = UNMutableNotificationContent()
        content.title = "Time's up! 🔒"
        content.body = "Your earned time just ran out. Open MathGate to solve another problem."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request  = UNNotificationRequest(identifier: NotifID.expiry, content: content, trigger: trigger)
        notificationCenter.add(request)
    }

    // MARK: - Formatted Time

    var formattedTimeRemaining: String {
        let m = timeRemainingSeconds / 60
        let s = timeRemainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    // MARK: - Keys

    private enum Keys {
        static let unlockExpiry    = "mg_unlockExpiry"
        static let blockedAppNames = "mg_blockedAppNames"
        static let timeCap         = "mg_timeCap"
    }

    private enum NotifID {
        static let expiry = "mg_timeExpired"
    }
}
