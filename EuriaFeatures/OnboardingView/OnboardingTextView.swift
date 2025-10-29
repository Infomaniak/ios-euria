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
import EuriaCoreUI
import EuriaResources
import SwiftUI

enum OnboardingText {
    case euria
    case datacenter
    case ephemeral
    case privacy
    case login

    private var title: String {
        switch self {
        case .euria:
            EuriaResourcesStrings.onboardingEuriaTitle
        case .datacenter:
            EuriaResourcesStrings.onboardingDatacenterTitle
        case .ephemeral:
            EuriaResourcesStrings.onboardingEphemeralTitle
        case .privacy:
            EuriaResourcesStrings.onboardingPrivacyTitle
        case .login:
            EuriaResourcesStrings.onboardingLoginTitle
        }
    }

    var subtitle: AttributedString {
        var result = AttributedString(title) + AttributedString("\n") + AttributedString(description)
        result.font = .Euria.specificTitleLight

        if let argumentRange = result.range(of: description) {
            result[argumentRange].font = .Euria.specificTitleMedium
        }

        return result
    }

    private var description: String {
        switch self {
        case .euria:
            EuriaResourcesStrings.onboardingEuriaDescription
        case .datacenter:
            EuriaResourcesStrings.onboardingDatacenterDescription
        case .ephemeral:
            EuriaResourcesStrings
                .onboardingEphemeralDescriptionTemplate(EuriaResourcesStrings.onboardingEphemeralDescriptionArguments)
        case .privacy:
            EuriaResourcesStrings.onboardingPrivacyDescription
        case .login:
            EuriaResourcesStrings.onboardingLoginTemplate(EuriaResourcesStrings.onboardingLoginArguments)
        }
    }
}

struct OnboardingTextView: View {
    let text: OnboardingText

    var body: some View {
        VStack(spacing: IKPadding.mini) {
            Text(text.subtitle)
        }
        .multilineTextAlignment(.center)
    }
}
