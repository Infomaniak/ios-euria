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

import DesignSystem
import SwiftUI

enum OnboardingText {
    case slide1
    case slide2
    case slide3

    var title: String {
        switch self {
        case .slide1:
            return "title1"
        case .slide2:
            return "title2"
        case .slide3:
            return "title3"
        }
    }

    var subtitle: String {
        switch self {
        case .slide1:
            return "onboarding_slide_1_text"
        case .slide2:
            return "onboarding_slide_2_text"
        case .slide3:
            return "onboarding_slide_3_text"
        }
    }
}

struct OnboardingTextView: View {
    let text: OnboardingText

    var body: some View {
        VStack(spacing: IKPadding.mini) {
            Text(text.title)
                .font(.title)
            Text(text.subtitle)
        }
        .multilineTextAlignment(.center)
    }
}
