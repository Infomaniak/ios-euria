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

import SwiftUI

public extension Font {
    @frozen enum Euria {
        /// Figma name: *Spécifique 22 Medium*
        public static let specificTitleMedium = Font.dynamicTypeSizeFont(size: 22, weight: .medium, relativeTo: .title)
        /// Figma name: *Spécifique 22 Light*
        public static let specificTitleLight = Font.dynamicTypeSizeFont(size: 22, weight: .light, relativeTo: .title)
    }

    /// Create a custom font with the UIFont preferred font family.
    /// - Parameters:
    ///   - size: Default size of the font for the "large" `Dynamic Type Size`.
    ///   - weight: Weight of the font.
    ///   - textStyle: The text style on which the font will be based to scale.
    ///
    /// - Returns: A font with the specified attributes.
    ///
    /// SwiftUI will use the default system font with the specified weight and size use `Dynamic Type Size`.
    private static func dynamicTypeSizeFont(size: CGFloat, weight: Weight, relativeTo textStyle: TextStyle) -> Font {
        let fontFamily = UIFont.preferredFont(forTextStyle: .body).familyName
        return custom(fontFamily, size: size, relativeTo: textStyle).weight(weight)
    }
}
