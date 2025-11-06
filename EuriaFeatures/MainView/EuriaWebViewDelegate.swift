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
import InfomaniakCore
import InfomaniakDI
import InfomaniakLogin
import OSLog
import Sentry
import SwiftUI
import UIKit
import WebKit

@MainActor
class EuriaWebViewDelegate: NSObject, ObservableObject {
    @Published var isLoaded = false

    @Published var isPresentingDocument: URL?
    @Published var error: ErrorDomain?

    let webConfiguration: WKWebViewConfiguration
    var downloads = [WKDownload: URL]()

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

    init(session: any UserSessionable) {
        webConfiguration = WKWebViewConfiguration()
        super.init()
        setupWebViewConfiguration(token: session.apiFetcher.currentToken)
    }

    deinit {
        Task {
            await EuriaWebViewDelegate.cleanTemporaryFolder()
        }
    }

    private func setupWebViewConfiguration(token: ApiToken?) {
        addCookies(token: token)
        addUserContentControllers()
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

    private func addUserContentControllers() {
        for topic in EuriaWebViewDelegate.MessageTopic.allCases {
            webConfiguration.userContentController.add(self, name: topic.rawValue)
        }
    }

    private func createCookie(cookie: EuriaWebViewDelegate.Cookie, value: String) -> HTTPCookie? {
        return HTTPCookie(
            properties: [
                .name: cookie.rawValue,
                .value: value,
                .path: "/",
                .domain: ApiEnvironment.current.euriaHost,
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
}

// MARK: - WKNavigationDelegate

extension EuriaWebViewDelegate: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard !navigationAction.shouldPerformDownload else {
            return .download
        }

        guard let navigationHost = navigationAction.request.url?.host() else {
            return .allow
        }

        if navigationHost == ApiEnvironment.current.euriaHost {
            return .allow
        }

        if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
            await UIApplication.shared.open(url)
        }
        return .cancel
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoaded = true
    }

    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        download.delegate = self
    }
}

// MARK: - WKDownloadDelegate

extension EuriaWebViewDelegate: WKDownloadDelegate {
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String) async -> URL? {
        do {
            let fileDestinationURL = try URL.temporaryDownloadsDirectory().appending(path: suggestedFilename)
            guard !FileManager.default.fileExists(atPath: fileDestinationURL.path(percentEncoded: false)) else {
                isPresentingDocument = fileDestinationURL
                return nil
            }

            downloads[download] = fileDestinationURL
            return fileDestinationURL
        } catch {
            self.error = .urlGenerationFailed(error: error)
            Logger.general.error("Error while generating the destination URL for a download: \(error)")
            return nil
        }
    }

    func downloadDidFinish(_ download: WKDownload) {
        guard let fileURL = downloads[download] else {
            return
        }

        isPresentingDocument = fileURL
        downloads[download] = nil
    }

    func download(_ download: WKDownload, didFailWithError error: any Error, resumeData: Data?) {
        self.error = .downloadFailed(error: error)
        Logger.general.error("Error while downloading a file: \(error)")

        downloads[download] = nil
    }
}

// MARK: - WKScriptMessageHandler

extension EuriaWebViewDelegate: WKScriptMessageHandler {
    enum MessageTopic: String, CaseIterable {
        case logout
        case unauthenticated
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let topic = MessageTopic(rawValue: message.name) else { return }

        switch topic {
        case .logout:
            logoutUser()
        case .unauthenticated:
            userTokenIsInvalid()
        }
    }

    private func logoutUser() {
        Task {
            let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
            await webConfiguration.websiteDataStore.removeData(
                ofTypes: dataTypes,
                modifiedSince: Date(timeIntervalSinceReferenceDate: 0)
            )

            @InjectService var accountManager: AccountManagerable
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
}
