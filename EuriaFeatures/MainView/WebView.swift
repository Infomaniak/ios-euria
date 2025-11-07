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

import InfomaniakCore
import SwiftUI
import UIKit
import WebKit

final class EuriaWebView: WKWebView {
    override var inputAccessoryView: UIView? {
        return nil
    }
}

struct WebView<WebViewCoordinator>: UIViewRepresentable {
    let url: URL
    let webConfiguration: WKWebViewConfiguration
    var webViewCoordinator: WebViewCoordinator?

    init(url: URL, webConfiguration: WKWebViewConfiguration = WKWebViewConfiguration(), webViewCoordinator: WebViewCoordinator?) {
        self.url = url
        self.webConfiguration = webConfiguration
        self.webViewCoordinator = webViewCoordinator
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = EuriaWebView(frame: .zero, configuration: webConfiguration)
        setupWebView(webView, coordinator: webViewCoordinator)

        let request = URLRequest(url: url)
        webView.load(request)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard webView.url != url else {
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)
    }

    private func setupWebView(_ webView: WKWebView, coordinator webViewCoordinator: WebViewCoordinator?) {
        setupDelegates(webView, coordinator: webViewCoordinator)
        configureScrollView(webView)
        removeBackground(webView)

        #if DEBUG
        webView.isInspectable = true
        #endif
    }

    private func setupDelegates(_ webView: WKWebView, coordinator webViewCoordinator: WebViewCoordinator?) {
        if let navigationDelegate = webViewCoordinator as? WKNavigationDelegate {
            webView.navigationDelegate = navigationDelegate
        }
        if let uiDelegate = webViewCoordinator as? WKUIDelegate {
            webView.uiDelegate = uiDelegate
        }

        let request = URLRequest(url: url)
        webView.load(request)
    }

    private func configureScrollView(_ webView: WKWebView) {
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.keyboardDismissMode = .interactive
    }

    private func removeBackground(_ webView: WKWebView) {
        webView.scrollView.backgroundColor = .clear
        webView.backgroundColor = .clear
        webView.isOpaque = false
    }
}
