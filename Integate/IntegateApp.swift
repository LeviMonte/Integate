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
                .fullScreenCover(isPresented: Binding(
                    get: { !hasSeenOnboarding },
                    set: { newValue in
                        // Only honor dismissal, never re-presentation.
                        if !newValue { hasSeenOnboarding = true }
                    }
                )) {
                    OnboardingView { hasSeenOnboarding = true }
                }
                .task {
                    // Refresh authorization status each launch (in case user changed it in Settings)
                    screenTime.refreshAuthorizationStatus()
                }
                // Must be applied OUTSIDE .fullScreenCover so the presented
                // OnboardingView inherits them too — presentation content only
                // sees environment injected above the presentation modifier.
                .environmentObject(screenTime)
                .environmentObject(streaks)
                .environmentObject(progress)
        }
    }
}
