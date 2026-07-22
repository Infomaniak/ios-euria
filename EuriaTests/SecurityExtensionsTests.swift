/*
 Infomaniak Euria - iOS App
 Copyright (C) 2026 Infomaniak Network SA

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

@testable import EuriaCore
import InfomaniakCore
import XCTest

final class SecurityExtensionsTests: XCTestCase {
    func testEscapedForJavaScriptStringEscapesExecutableDelimiters() {
        let query = "chat\\\"><script>\\path\n\u{2028}\u{2029}"

        XCTAssertEqual(
            query.escapedForJavaScriptString(),
            "chat\\u005C\\u0022\\u003E\\u003Cscript\\u003E\\u005Cpath\\u000A\\u2028\\u2029"
        )
    }

    func testEscapedForJavaScriptStringPreservesSafeQueryCharacters() {
        let query = "/chat?id=123&mode=voice"

        XCTAssertEqual(query.escapedForJavaScriptString(), query)
    }

    func testAllowedUpgradeURLAcceptsCurrentEnvironmentDomain() {
        let host = ApiEnvironment.current.host

        XCTAssertTrue(isAllowedUpgradeURL("https://\(host)/upgrade"))
        XCTAssertTrue(isAllowedUpgradeURL("https://manager.\(host)/v3/mobile_login?url=%2Fupgrade"))
        XCTAssertTrue(isAllowedUpgradeURL("https://shop.\(host)/order"))
    }

    func testAllowedUpgradeURLRejectsUntrustedURLs() {
        let otherInfomaniakHost = ApiEnvironment.current.host == "infomaniak.com" ? "infomaniak.ch" : "infomaniak.com"

        XCTAssertFalse(isAllowedUpgradeURL("http://manager.infomaniak.com/upgrade"))
        XCTAssertFalse(isAllowedUpgradeURL("https://manager.infomaniak.com.evil.example/upgrade"))
        XCTAssertFalse(isAllowedUpgradeURL("https://manager.infomaniak.com@evil.example/upgrade"))
        XCTAssertFalse(isAllowedUpgradeURL("https://manager.\(otherInfomaniakHost)/upgrade"))
        XCTAssertFalse(isAllowedUpgradeURL("https://notinfomaniak.com/upgrade"))
        XCTAssertFalse(isAllowedUpgradeURL("not a url"))
    }

    private func isAllowedUpgradeURL(_ value: String) -> Bool {
        return URL(string: value)?.isAllowedUpgradeURL ?? false
    }
}
