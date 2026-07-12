//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Customizes the iOS block screen that appears when a user taps a restricted app.
//  This is a separate app extension target — see SETUP notes in SETUP.md.
//
//  REQUIRES in Xcode (this extension target):
//    Linked Framework: ManagedSettingsUI
//    Signing & Capabilities → App Groups → group.com.levimonte.integate
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    // MARK: - Single app blocked

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        makeConfig(blockedName: application.localizedDisplayName)
    }

    override func configuration(shielding application: Application,
                                 in domain: ActivityCategoryToken) -> ShieldConfiguration {
        makeConfig(blockedName: application.localizedDisplayName)
    }

    // MARK: - Web domain blocked

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        makeConfig(blockedName: webDomain.domain.map { "www.\($0)" })
    }

    // MARK: - Category blocked

    override func configuration(shielding category: ActivityCategory) -> ShieldConfiguration {
        makeConfig(blockedName: nil)
    }

    // MARK: - Shared builder

    private func makeConfig(blockedName: String?) -> ShieldConfiguration {
        let appName   = appDisplayName()
        let icon      = UIImage(systemName: "function")?
                            .withTintColor(.white, renderingMode: .alwaysOriginal)

        return ShieldConfiguration(
            backgroundBlurStyle:         .systemUltraThinMaterialDark,
            backgroundColor:             UIColor(red: 0.20, green: 0.00, blue: 0.40, alpha: 1.0),
            icon:                        icon,
            title:  ShieldConfiguration.Label(
                text:  "Solve to Unlock",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text:  "Open \(appName) and solve a math problem to access this app.",
                color: UIColor.white.withAlphaComponent(0.72)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text:  "Open \(appName) →",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.35, green: 0.10, blue: 0.60, alpha: 0.90),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text:  "Stay Focused",
                color: UIColor.white.withAlphaComponent(0.45)
            )
        )
    }

    // MARK: - Helpers

    /// Reads the app display name from this extension's bundle (falls back to "Integate").
    private func appDisplayName() -> String {
        // The extension bundle is inside the main app bundle, so we walk up.
        // Simpler: just hardcode your chosen app name here.
        return "Integate"   // ← update this when you rename the app
    }
}
