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

public struct IdentifiableURL: Identifiable, Equatable {
    public var id: String { return url.absoluteString }
    public let url: URL

    init(url: URL) {
        self.url = url
    }

    init?(string: String) {
        guard let url = URL(string: string) else { return nil }
        self.init(url: url)
    }
}

public struct UniversalLinkHandler: Sendable {
    public init() {}

    public func handlePossibleUniversalLink(_ url: URL) -> IdentifiableURL? {
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

    private func tryToHandleEuriaUniversalLink(_ url: URL) -> IdentifiableURL? {
        guard url.host() == ApiEnvironment.current.euriaHost else { return nil }
        return IdentifiableURL(url: url)
    }

    private func tryToHandleKSuiteUniversalLink(_ url: URL) -> IdentifiableURL? {
        let urlPath = url.path()

        if urlPath.starts(with: "/all"), let range = urlPath.range(of: "euria") {
            let remainingPath = String(urlPath[range.upperBound...])
            return IdentifiableURL(string: "https://\(ApiEnvironment.current.euriaHost)\(remainingPath)")
        } else {
            let remainingPath = urlPath.replacingOccurrences(of: "/euria", with: "")
            return IdentifiableURL(string: "https://\(ApiEnvironment.current.euriaHost)\(remainingPath)")
        }
    }

    private func tryToHandleWidgetLink(_ url: URL) -> IdentifiableURL? {
        if url == DeeplinkConstants.newChatURL {
            return IdentifiableURL(string: "https://\(ApiEnvironment.current.euriaHost)")
        }
        if url == DeeplinkConstants.ephemeralURL {
            return IdentifiableURL(string: "link1")
        }
        if url == DeeplinkConstants.speechURL {
            return IdentifiableURL(string: "link2")
        }
        return nil
    }
}
