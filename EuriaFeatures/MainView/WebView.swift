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

import EuriaCoreUI
import InfomaniakCore
import SwiftUI
import UIKit
import WebKit

struct WebView: UIViewRepresentable {
    @EnvironmentObject private var mainViewState: MainViewState
    let url: URL
    var webConfiguration = WKWebViewConfiguration()
    var navigationDelegate: WKNavigationDelegate?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        if let navigationDelegate {
            webView.navigationDelegate = navigationDelegate
        }
        let request = URLRequest(url: url)
        webView.load(request)
        #if DEBUG
        webView.isInspectable = true
        #endif
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update the view.
    }
}
