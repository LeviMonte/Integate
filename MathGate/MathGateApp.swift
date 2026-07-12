import SwiftUI
import FamilyControls

@main
struct IntegateApp: App {
    @StateObject private var screenTime  = ScreenTimeManager()
    @StateObject private var streaks     = StreakManager()
    @StateObject private var progress    = UserProgress()

    @AppStorage("mg_hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(screenTime)
                .environmentObject(streaks)
                .environmentObject(progress)
                .fullScreenCover(isPresented: Binding(
                    get: { !hasSeenOnboarding },
                    set: { _ in }
                )) {
                    OnboardingView { hasSeenOnboarding = true }
                }
                .task {
                    // Refresh authorization status each launch (in case user changed it in Settings)
                    screenTime.refreshAuthorizationStatus()
                }
        }
    }
}
