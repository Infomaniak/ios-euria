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

import Foundation
import InfomaniakCore

public extension String {
    func escapedForJavaScriptString() -> String {
        return unicodeScalars.reduce(into: "") { result, scalar in
            let value = scalar.value
            let shouldEscape = value <= 0x1F
                || value == 0x22
                || value == 0x3C
                || value == 0x3E
                || value == 0x5C
                || value == 0x2028
                || value == 0x2029

            guard shouldEscape else {
                result.unicodeScalars.append(scalar)
                return
            }

            let hexadecimalValue = String(value, radix: 16, uppercase: true)
            result += "\\u\(String(repeating: "0", count: 4 - hexadecimalValue.count))\(hexadecimalValue)"
        }
    }
}

public extension URL {
    var isAllowedUpgradeURL: Bool {
        guard scheme?.lowercased() == "https", let normalizedHost = host()?.lowercased() else {
            return false
        }

        let environmentHost = ApiEnvironment.current.host.lowercased()
        return normalizedHost == environmentHost || normalizedHost.hasSuffix(".\(environmentHost)")
    }
}
