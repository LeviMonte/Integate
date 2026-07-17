//
//  ShieldConfigurationExtension.swift
//  ShieldConfigExtension
//
//  Customizes the iOS block screen that appears when a user taps a restricted app.
//
//  REQUIRES in Xcode (this extension target):
//    Linked Frameworks: ManagedSettingsUI, ManagedSettings
//    Signing & Capabilities → App Groups → group.com.monte.integate
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
                                in category: ActivityCategory) -> ShieldConfiguration {
        makeConfig(blockedName: application.localizedDisplayName)
    }

    // MARK: - Web domain blocked

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        makeConfig(blockedName: webDomain.domain.map { "www.\($0)" })
    }

    override func configuration(shielding webDomain: WebDomain,
                                in category: ActivityCategory) -> ShieldConfiguration {
        makeConfig(blockedName: webDomain.domain.map { "www.\($0)" })
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

    /// The app display name shown on the shield.
    private func appDisplayName() -> String {
        return "Integate"
    }
}
