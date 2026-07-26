//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Re-applies shields when earned screen time expires — even while Integate
//  is suspended. This is the ONLY reliable way to re-lock: the in-app Timer
//  in ScreenTimeManager stops running the moment the user leaves Integate.
//
//  Two triggers, matching ScreenTimeManager's two timer modes:
//    • intervalDidEnd      → continuous mode: a fixed wall-clock window ended.
//    • eventDidReachThreshold → active-use mode: cumulative usage of the
//                               blocked apps/categories hit the earned budget.
//
//  iOS launches this extension for whichever mode ScreenTimeManager scheduled
//  in grantTime(seconds:) (see startWallClockMonitoring / startActiveUseMonitoring).
//
//  REQUIRES in Xcode (this extension target):
//    Linked Frameworks: DeviceActivity, ManagedSettings, FamilyControls
//    Signing & Capabilities → App Groups → group.com.monte.integate
//

import DeviceActivity
import ManagedSettings
import FamilyControls
import Foundation
import UserNotifications

class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    // ⚠️ Must match ScreenTimeManager.appGroupID
    private let appGroupID = "group.com.monte.integate"
    private let store = ManagedSettingsStore()

    // Must match ScreenTimeManager's private Activity/EventName enums.
    private let continuousActivity = DeviceActivityName("mg_earnedTime")
    private let activeUseActivity  = DeviceActivityName("mg_earnedTime_active")
    private let usageThresholdEvent = DeviceActivityEvent.Name("mg_usageThreshold")

    /// Continuous mode: the wall-clock window scheduled at grant time is over.
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        guard activity == continuousActivity else { return }
        reapplyShields()
    }

    /// Active-use mode: cumulative usage of the blocked apps/categories has
    /// reached the earned budget.
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        guard activity == activeUseActivity, event == usageThresholdEvent else { return }
        reapplyShields()
        markActiveUseExpired()
        notifyTimeExpired()
    }

    private func reapplyShields() {
        let defaults = UserDefaults(suiteName: appGroupID)

        // Mark expiry as consumed so the main app syncs state on next launch.
        defaults?.removeObject(forKey: "mg_unlockExpiry")

        guard
            let data = defaults?.data(forKey: "mg_activitySelection"),
            let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else { return }

        let apps = selection.applicationTokens
        let cats = selection.categoryTokens
        store.shield.applications          = apps.isEmpty ? nil : apps
        store.shield.applicationCategories = cats.isEmpty ? nil : .specific(cats)
    }

    /// Signals ScreenTimeManager (via the shared app group) that the
    /// active-use budget ran out, so it can update its own @Published state
    /// next time Integate is foregrounded or launched.
    private func markActiveUseExpired() {
        UserDefaults(suiteName: appGroupID)?.set(true, forKey: "mg_activeUseExpired")
    }

    /// Continuous mode's expiry notification is scheduled in advance by
    /// ScreenTimeManager (it knows the exact expiry time). Active-use mode
    /// doesn't know the real expiry time in advance, so this extension posts
    /// it directly the moment the threshold actually fires.
    private func notifyTimeExpired() {
        let content   = UNMutableNotificationContent()
        content.title = "Time's up! 🔒"
        content.body  = "You've used up your earned screen time. Solve another problem to unlock more."
        content.sound = .default
        let request = UNNotificationRequest(identifier: "mg_timeExpired_active", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
