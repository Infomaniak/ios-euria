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
import EuriaOnboardingView
import InfomaniakCore
import InfomaniakDI
import InfomaniakLogin
import OSLog
import Sentry
import SwiftUI
import UIKit
import WebKit

@MainActor
final class EuriaWebViewDelegate: NSObject, WebViewCoordinator, WebViewBridge, ObservableObject {
    @Published var isLoaded = false
    @Published var isShowingRegisterView = false
    @Published var isShowingReviewAlert = false
    @Published var upgradeViewToken: UpgradeTokenItem?

    @Published var isPresentingDocument: URL?
    @Published var error: ErrorDomain?
    let loginHandler = LoginHandler()

    let host: String
    let webConfiguration: WKWebViewConfiguration

    private(set) weak var uploadManager: UploadManager?

    var downloads = [WKDownload: URL]()

    var isReadyToReceiveEvents = false
    private var pendingDestination: String?
    private var pendingUploadSession: String?

    weak var webView: WKWebView?
    var subscribers: [JSMessageTopic: any WebViewMessageSubscriber] = [:]

    enum Cookie: String {
        case userToken = "USER-TOKEN"
        case userLanguage = "USER-LANGUAGE"
    }

    enum ErrorDomain: LocalizedError, Equatable {
        case urlGenerationFailed(error: Error)
        case downloadFailed(error: Error)

        var errorDescription: String? {
            switch self {
            case .urlGenerationFailed(let error):
                return error.localizedDescription
            case .downloadFailed(let error):
                return error.localizedDescription
            }
        }

        static func == (lhs: ErrorDomain, rhs: ErrorDomain) -> Bool {
            switch (lhs, rhs) {
            case (.urlGenerationFailed, .urlGenerationFailed):
                return true
            case (.downloadFailed, .downloadFailed):
                return true
            default:
                return false
            }
        }
    }

    init(host: String, session: any UserSessionable) {
        self.host = host
        webConfiguration = WKWebViewConfiguration()

        super.init()
        setupWebViewConfiguration(token: session.apiFetcher.currentToken)
    }

    deinit {
        Task {
            await EuriaWebViewDelegate.cleanTemporaryFolder()
        }
    }

    func setUploadManager(_ manager: UploadManager) {
        uploadManager = manager
    }

    private func setupWebViewConfiguration(token: ApiToken?) {
        addCookies(token: token)
        addSubscriber(self, topic: .keepDeviceAwake)
        addSubscriber(self, topic: .logIn)
        addSubscriber(self, topic: .logout)
        addSubscriber(self, topic: .ready)
        addSubscriber(self, topic: .signUp)
        addSubscriber(self, topic: .unauthenticated)
        addSubscriber(self, topic: .openReview)
        addSubscriber(self, topic: .upgrade)
    }

    private func addCookies(token: ApiToken?) {
        let cookieStore = webConfiguration.websiteDataStore.httpCookieStore

        if let token, let tokenCookie = createCookie(cookie: .userToken, value: "\(token.accessToken)") {
            cookieStore.setCookie(tokenCookie)
        }

        let language = Locale.current.language.languageCode?.identifier ?? "en"
        if let languageCookie = createCookie(cookie: .userLanguage, value: language) {
            cookieStore.setCookie(languageCookie)
        }
    }

    private func createCookie(cookie: EuriaWebViewDelegate.Cookie, value: String) -> HTTPCookie? {
        return HTTPCookie(
            properties: [
                .name: cookie.rawValue,
                .value: value,
                .path: "/",
                .domain: host,
                .maximumAge: TimeInterval.sixMonths
            ]
        )
    }

    private nonisolated static func cleanTemporaryFolder() async {
        do {
            try FileManager.default.removeItem(at: URL.temporaryDownloadsDirectory())
        } catch {
            Logger.general.error("Error while cleaning temporary folder: \(error)")
        }
    }

    func enqueueNavigation(destination: String) {
        pendingDestination = destination
        navigateIfPossible()
    }

    func enqueueUpload(importSession: String) {
        pendingUploadSession = importSession
        navigateIfPossible()
    }

    func navigateIfPossible() {
        guard isReadyToReceiveEvents else {
            return
        }

        if let pendingUploadSession {
            @InjectService var accountManager: AccountManagerable

            Task {
                if let session = await accountManager.currentSession,
                   let uploadManager {
                    try? await Task.sleep(for: .milliseconds(200))
                    uploadManager.handleImportSession(uuid: pendingUploadSession, userSession: session)
                }
            }
        }

        if let destination = pendingDestination {
            pendingDestination = nil

            Task {
                // Sometimes, when navigating from a universal link, Euria can’t access the local storage right away,
                // which causes the user to be logged out.
                // To avoid this situation, we wait a few milliseconds.
                try? await Task.sleep(for: .milliseconds(200))
                await callFunction(GoToDestination(destination: destination))
            }
        }
    }

    func callFunction<M: JSFunction>(_ function: M) async -> M.Result? {
        guard let webView else { return nil }
        do {
            return try await webView.evaluateJavaScript(function.declaration) as? M.Result
        } catch {
            Logger.general.error("Error while sending message to webview: \(error)")
            return nil
        }
    }

    func addSubscriber(_ subscriber: any WebViewMessageSubscriber, topic: JSMessageTopic) {
        if subscribers[topic] == nil {
            webConfiguration.userContentController.add(self, name: topic.rawValue)
        }
        subscribers[topic] = subscriber
    }

    func updateSessionToken(_ session: any UserSessionable) {
        if let token = session.apiFetcher.currentToken {
            addCookies(token: token)
            reloadWebView()
        }
    }

    func reloadWebView() {
        isLoaded = false
        isReadyToReceiveEvents = false
        webView?.reload()
    }

    func uploadCameraImage(image: UIImage, session: UserSessionable, uploadManager: UploadManager) {
        Task {
            guard let data = image.jpegData(compressionQuality: 0.9),
                  let containerURL = FileManager.default
                  .containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier) else {
                return
            }

            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("camera-\(UUID().uuidString).jpg")

            do {
                try data.write(to: tempURL)

                let importHelper = ImportHelper(baseURL: containerURL)
                try await importHelper.moveURLsToImportDirectory([tempURL])

                uploadManager.handleImportSession(uuid: importHelper.importUUID, userSession: session)
            }
        }
    }
}

struct UpgradeTokenItem: Identifiable {
    var id: String { return token.accessToken }
    let token: ApiToken
}
