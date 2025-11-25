/*
 Infomaniak Euria - iOS App
 Copyright (C) 2025 Infomaniak Network SA

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import DeviceAssociation
import Foundation
import InAppTwoFactorAuthentication
import InfomaniakCore
import InfomaniakCoreCommonUI
import InfomaniakDI
import InfomaniakLogin
import InfomaniakNotifications
import InterAppLogin
import OSLog
import Sentry

extension [Factory] {
    func registerFactoriesInDI() {
        forEach { SimpleResolver.sharedResolver.store(factory: $0) }
    }
}

/// Each target should subclass `TargetAssembly` and override `getTargetServices` to provide additional, target related, services.
@MainActor
open class TargetAssembly {
    private static let logger = Logger(category: "TargetAssembly")
    private static let realmRootPath = "chats"

    private static let apiEnvironment: ApiEnvironment = .preprod
    public static let loginConfig = InfomaniakLogin.Config(
        clientId: "10476B29-7B98-4D42-B06B-2B7AB0F06FDE",
        loginURL: URL(string: "https://login.\(apiEnvironment.host)/")!,
        accessType: nil
    )

    public init() {
        ApiEnvironment.current = Self.apiEnvironment
        Self.setupDI()
    }

    open class func getCommonServices() -> [Factory] {
        return [
            Factory(type: ConnectedAccountManagerable.self) { _, _ in
                ConnectedAccountManager(currentAppKeychainIdentifier: AppIdentifierBuilder.euriaKeychainIdentifier)
            },
            Factory(type: InAppTwoFactorAuthenticationManagerable.self) { _, _ in
                InAppTwoFactorAuthenticationManager()
            },
            Factory(type: InfomaniakNetworkLoginable.self) { _, _ in
                InfomaniakNetworkLogin(config: loginConfig)
            },
            Factory(type: InfomaniakLoginable.self) { _, _ in
                InfomaniakLogin(config: loginConfig)
            },
            Factory(type: KeychainHelper.self) { _, _ in
                KeychainHelper(accessGroup: Constants.accessGroup)
            },
            Factory(type: PlatformDetectable.self) { _, _ in
                PlatformDetector()
            },
            Factory(type: AccountManagerable.self) { _, _ in
                AccountManager()
            },
            Factory(type: AppGroupPathProvidable.self) { _, _ in
                guard let provider = AppGroupPathProvider(
                    realmRootPath: realmRootPath,
                    appGroupIdentifier: Constants.appGroupIdentifier
                ) else {
                    fatalError("could not safely init AppGroupPathProvider")
                }

                return provider
            },
            Factory(type: DeviceManagerable.self) { _, _ in
                let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String? ?? "x.x"
                return DeviceManager(appGroupIdentifier: Constants.sharedAppGroupName,
                                     appMarketingVersion: version,
                                     capabilities: [.twoFactorAuthenticationChallengeApproval])
            },
            Factory(type: TokenStore.self) { _, _ in
                TokenStore()
            },
            Factory(type: AppLaunchCounter.self) { _, _ in
                AppLaunchCounter()
            },
            Factory(type: OrientationManageable.self) { _, _ in
                OrientationManager()
            },
            Factory(type: InfomaniakNotifications.self) { _, _ in
                InfomaniakNotifications(appGroup: Constants.appGroupIdentifier)
            },
            Factory(type: ReviewManageable.self) { _, _ in
                ReviewManager(userDefaults: UserDefaults.shared)
            },
            Factory(type: MatomoUtils.self) { _, _ in
                let matomo = MatomoUtils(siteId: MatomoUtils.euriaSiteID, baseURL: MatomoUtils.siteURL)
                #if DEBUG
                matomo.optOut(true)
                #endif
                return matomo
            }
        ]
    }

    open class func getTargetServices() -> [Factory] {
        logger.warning("targetServices is not implemented in subclass ? Did you forget to override ?")
        return []
    }

    public static func setupDI() {
        (getCommonServices() + getTargetServices()).registerFactoriesInDI()
    }
}
