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
import SwiftUI

public struct ShareExtensionHandler: Sendable {
    public init() {}

    public func fetchLastSharedImage() -> UIImage? {
        guard
            let userDefaults = UserDefaults(suiteName: Constants.appGroupIdentifier),
            let sharedImagePath = userDefaults.string(forKey: "sharedImagePath")
        else { return nil }

        guard FileManager.default.fileExists(atPath: sharedImagePath) else { return nil }
        let sharedImage = UIImage(contentsOfFile: sharedImagePath)

        try? FileManager.default.removeItem(atPath: sharedImagePath)
        userDefaults.removeObject(forKey: "sharedImagePath")

        return sharedImage
    }
}
