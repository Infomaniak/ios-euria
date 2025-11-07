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

import AVFoundation
import Foundation
import OSLog
import Sentry
import WebKit

extension EuriaWebViewDelegate: WKUIDelegate {
    func webView(
        _ webView: WKWebView,
        decideMediaCapturePermissionsFor origin: WKSecurityOrigin,
        initiatedBy frame: WKFrameInfo,
        type: WKMediaCaptureType
    ) async -> WKPermissionDecision {
        switch type {
        case .camera:
            let canAccessCamera = await canAccessCamera()
            return canAccessCamera ? .grant : .deny

        case .microphone:
            let canAccessMicrophone = await canAccessMicrophone()
            return canAccessMicrophone ? .grant : .deny

        case .cameraAndMicrophone:
            let canAccessCamera = await canAccessCamera()
            let canAccessMicrophone = await canAccessMicrophone()
            return canAccessCamera && canAccessMicrophone ? .grant : .deny

        @unknown default:
            Logger.general.info("The WebView asked for a permission we do not handle.")
            SentrySDK.capture(message: "The WebView asked for a permission we do not handle.") { scope in
                scope.setContext(value: ["Type RawValue": type.rawValue], key: "Information")
            }
            return .prompt
        }
    }

    private func canAccessCamera() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        if status == .notDetermined {
            return await AVCaptureDevice.requestAccess(for: .video)
        }

        return status == .authorized
    }

    private func canAccessMicrophone() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)

        if status == .notDetermined {
            return await AVCaptureDevice.requestAccess(for: .audio)
        }

        return status == .authorized
    }
}
