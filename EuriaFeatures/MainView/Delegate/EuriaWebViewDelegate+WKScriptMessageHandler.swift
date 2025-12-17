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
import InfomaniakDI
import Sentry
import WebKit

// MARK: - WKScriptMessageHandler

extension EuriaWebViewDelegate: WKScriptMessageHandler, WebViewMessageSubscriber {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let topic = JSMessageTopic(rawValue: message.name) else { return }

        subscribers[topic]?.handleMessage(topic: topic, body: message.body)
    }

    func handleMessage(topic: JSMessageTopic, body: Any) {
        @InjectService var accountManager: AccountManagerable
        switch topic {
        case .logout:
            logoutUser()
        case .unauthenticated:
            userTokenIsInvalid()
        case .keepDeviceAwake:
            guard let shouldKeepDeviceAwake = body as? Bool else { return }
            keepDeviceAwake(shouldKeepDeviceAwake)
        case .ready:
            isReadyToReceiveEvents = true
            navigateIfPossible()
        case .logIn:
            Task {
                await loginHandler.login()
            }
        case .signUp:
            isShowingRegisterView = true
        case .openReview:
            isShowingReviewAlert = true
        case .upgrade:
            Task {
                let session = await accountManager.currentSession
                guard let token = session?.apiFetcher.currentToken else {
                    upgradeViewToken = nil
                    return
                }
                upgradeViewToken = UpgradeTokenItem(token: token)
            }
        default:
            break
        }
    }

    private func logoutUser() {
        Task {
            @InjectService var accountManager: AccountManagerable
            if await accountManager.currentSession?.isGuest == true {
                return
            }

            let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
            await webConfiguration.websiteDataStore.removeData(
                ofTypes: dataTypes,
                modifiedSince: Date(timeIntervalSinceReferenceDate: 0)
            )

            guard let userId = await accountManager.currentSession?.userId else {
                return
            }

            await accountManager.removeTokenAndAccountFor(userId: userId)
        }
    }

    private func userTokenIsInvalid() {
        SentrySDK.capture(message: "Refreshing token failed - Cannot refresh infinite token") { scope in
            scope.setLevel(.error)
        }
        logoutUser()
    }

    private func keepDeviceAwake(_ shouldKeepDeviceAwake: Bool) {
        UIApplication.shared.isIdleTimerDisabled = shouldKeepDeviceAwake
    }
}
