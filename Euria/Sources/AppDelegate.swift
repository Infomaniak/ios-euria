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

import EuriaCore
import InfomaniakCoreCommonUI
import InfomaniakDI
import InfomaniakNotifications
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    private let notificationCenterDelegate = NotificationCenterDelegate()

    @LazyInjectService private var notificationService: InfomaniakNotifications
    @LazyInjectService private var accountManager: AccountManagerable

    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = notificationCenterDelegate
        application.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task {
            for account in await accountManager.accounts {
                Task {
                    /* Because of a backend issue we can't register the notification token directly after the creation or refresh of
                     an API token. We wait at least 15 seconds before trying to register. */
                    try? await Task.sleep(nanoseconds: 15_000_000_000)

                    let userApiFetcher = await accountManager.getApiFetcher(for: account.userId, token: account)
                    await notificationService.updateRemoteNotificationsToken(tokenData: deviceToken,
                                                                             userApiFetcher: userApiFetcher,
                                                                             updatePolicy: .always)
                }
            }
        }
    }

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        @InjectService var orientationManager: OrientationManageable
        return orientationManager.orientationLock
    }
}
