//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Handles button taps on the shield screen.
//
//  When the user taps "Open Integate →":
//    1. Writes mg_pendingUnlock = true into the shared App Group UserDefaults.
//    2. Returns .close to dismiss the shield.
//    3. The user is returned to the home screen and taps the Integate icon.
//    4. Integate reads hasPendingUnlockRequest on appear and shows a solve banner.
//
//  REQUIRES in Xcode (this extension target):
//    Linked Framework: ManagedSettings
//    Signing & Capabilities → App Groups → group.com.monte.integate
//

import ManagedSettings
import Foundation
import UserNotifications

class ShieldActionExtension: ShieldActionDelegate {

    // ⚠️ Must match ScreenTimeManager.appGroupID and the extension's App Group capability
    private let appGroupID = "group.com.monte.integate"

    // MARK: - Application tokens

    override func handle(action: ShieldAction,
                         for application: ApplicationToken,
                         completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            signalPendingUnlock()
            completionHandler(.close)  // dismiss shield → user opens Integate from home
        case .secondaryButtonPressed:
            completionHandler(.close)  // "Stay Focused" — just close the shield
        @unknown default:
            completionHandler(.close)
        }
    }

    // MARK: - Web domain tokens

    override func handle(action: ShieldAction,
                         for webDomain: WebDomainToken,
                         completionHandler: @escaping (ShieldActionResponse) -> Void) {
        if action == .primaryButtonPressed { signalPendingUnlock() }
        completionHandler(.close)
    }

    // MARK: - Category tokens

    override func handle(action: ShieldAction,
                         for category: ActivityCategoryToken,
                         completionHandler: @escaping (ShieldActionResponse) -> Void) {
        if action == .primaryButtonPressed { signalPendingUnlock() }
        completionHandler(.close)
    }

    // MARK: - Shared signal

    private func signalPendingUnlock() {
        UserDefaults(suiteName: appGroupID)?.set(true, forKey: "mg_pendingUnlock")
        fireUnlockNotification()
    }

    /// Fires an immediate notification so the user can tap it to jump straight into Integate.
    private func fireUnlockNotification() {
        let content      = UNMutableNotificationContent()
        content.title    = "Solve to unlock"
        content.body     = "Tap here to open Integate and solve a problem."
        content.sound    = .default
        // Fire in 0.5 s so the shield has time to close first
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "ig_solve_\(Int(Date().timeIntervalSince1970))",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
