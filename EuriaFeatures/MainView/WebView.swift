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

struct WebView: UIViewRepresentable {
    typealias WebViewDelegate = WKNavigationDelegate & WKScriptMessageHandler

    let url: URL
    var webConfiguration = WKWebViewConfiguration()
    var delegate: WebViewDelegate?

    func makeUIView(context: Context) -> WKWebView {
        let webView = EuriaWebView(frame: .zero, configuration: webConfiguration)

        if let delegate {
            webView.navigationDelegate = delegate
        }

        #if DEBUG
        webView.isInspectable = true
        #endif

        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.keyboardDismissMode = .interactive

        let request = URLRequest(url: url)
        webView.load(request)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update the view.
    }
}
