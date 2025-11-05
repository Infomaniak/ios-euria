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
import Foundation
import InAppTwoFactorAuthentication
import InfomaniakDI
import UIKit
import UserNotifications

@MainActor
final class NotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    @LazyInjectService private var accountManager: AccountManagerable

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        await handleTwoFactorAuthenticationNotification(notification)
        return []
    }

    func handleTwoFactorAuthenticationNotification(_ notification: UNNotification) async {
        @InjectService var inAppTwoFactorAuthenticationManager: InAppTwoFactorAuthenticationManagerable

        guard let userId = inAppTwoFactorAuthenticationManager.handleRemoteNotification(notification) else {
            return
        }

        let accounts = await accountManager.accounts

        guard !accounts.isEmpty else {
            UIApplication.shared.unregisterForRemoteNotifications()
            return
        }

        guard let account = accounts.first(where: { $0.userId == userId }),
              let user = await accountManager.userProfileStore.getUserProfile(id: userId) else {
            return
        }

        let apiFetcher = await accountManager.getApiFetcher(for: userId, token: account)

        let session = InAppTwoFactorAuthenticationSession(user: user, apiFetcher: apiFetcher)

        inAppTwoFactorAuthenticationManager.checkConnectionAttempts(using: session)
    }
}
