/*
 Infomaniak Euria - iOS App
 Copyright (C) 2025 Infomaniak Network SA

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import Lottie
import SwiftUI

public struct ThemedAnimation {
    private let light: String
    private let dark: String

    init(light: String, dark: String) {
        self.light = light
        self.dark = dark
    }

    func getLottieForCurrentScheme(colorScheme: ColorScheme? = nil) -> String {
        let fileName = colorScheme == .dark ? dark : light
        return fileName
    }
}

extension ThemedAnimation {
    static let onboardingEuria = ThemedAnimation(light: "euria-base", dark: "euria-base")
    static let onboardingPrivacy = ThemedAnimation(light: "conversation-bubbles-light", dark: "conversation-bubbles-dark")
    static let onboardingEphemeral = ThemedAnimation(light: "euria-base-ephemeral", dark: "euria-base-ephemeral")
}
