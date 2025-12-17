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

import Foundation
import InfomaniakCore
import InfomaniakCoreCommonUI
import InfomaniakDI

public struct NavigationDestination: Identifiable, Equatable {
    public var id: String { return string }
    public let string: String

    init(string: String) {
        self.string = string
    }
}

public struct UniversalLinkHandler: Sendable {
    public init() {}

    public func handlePossibleUniversalLink(_ url: URL) -> NavigationDestination? {
        if let widgetLink = tryToHandleWidgetLink(url) {
            return widgetLink
        }

        if let euriaUniversalLink = tryToHandleEuriaUniversalLink(url) {
            return euriaUniversalLink
        }

        if let kSuiteUniversalLink = tryToHandleKSuiteUniversalLink(url) {
            return kSuiteUniversalLink
        }

        return nil
    }

    public func handlePossibleImportSession(_ url: URL) -> ImportHelper.ImportSessionUUID? {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let sessionUUID = urlComponents?.queryItems?.first(where: { $0.name == "session_uuid" })?.value else {
            return nil
        }

        return sessionUUID
    }

    private func tryToHandleWidgetLink(_ url: URL) -> NavigationDestination? {
        @InjectService var matomoUtils: MatomoUtils

        switch url {
        case DeeplinkConstants.newChatURL:
            matomoUtils.track(eventWithCategory: .widget, name: "newChat")
            return NavigationDestination(string: "/")
        case DeeplinkConstants.ephemeralURL:
            matomoUtils.track(eventWithCategory: .widget, name: "ephemeralMode")
            return NavigationDestination(string: NavigationConstants.ephemeralRoute)
        case DeeplinkConstants.speechURL:
            matomoUtils.track(eventWithCategory: .widget, name: "enableMicrophone")
            return NavigationDestination(string: NavigationConstants.speechRoute)
        case DeeplinkConstants.cameraURL:
            matomoUtils.track(eventWithCategory: .widget, name: "openCamera")
            return NavigationDestination(string: NavigationConstants.cameraRoute)
        default:
            return nil
        }
    }

    private func tryToHandleEuriaUniversalLink(_ url: URL) -> NavigationDestination? {
        guard url.host() == ApiEnvironment.current.euriaHost else { return nil }
        return NavigationDestination(string: url.path())
    }

    private func tryToHandleKSuiteUniversalLink(_ url: URL) -> NavigationDestination? {
        guard url.scheme == "https" else { return nil }
        let urlPath = url.path()

        if urlPath.starts(with: "/all"), let range = urlPath.range(of: "euria") {
            let remainingPath = String(urlPath[range.upperBound...])
            return NavigationDestination(string: remainingPath)
        } else {
            let remainingPath = urlPath.replacingOccurrences(of: "/euria", with: "")
            return NavigationDestination(string: remainingPath)
        }
    }
}
