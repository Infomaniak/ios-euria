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

import EuriaResources
import InfomaniakOnboarding
import SwiftUI

extension Slide {
    static var onboardingSlides: [Slide] {
        return [
            Slide(
                backgroundImage: EuriaResourcesAsset.Images.onboardingBackground1.image,
                backgroundImageTintColor: nil,
                content: .animation(IKLottieConfiguration(
                    id: 1,
                    filename: "storage-cardboard-box",
                    bundle: EuriaResourcesResources.bundle
                )),
                bottomView: OnboardingTextView(text: .euria)
            ),
            Slide(
                backgroundImage: EuriaResourcesAsset.Images.onboardingBackground2.image,
                backgroundImageTintColor: nil,
                content: .animation(IKLottieConfiguration(
                    id: 2,
                    filename: "cards-transfer-type",
                    bundle: EuriaResourcesResources.bundle
                )),
                bottomView: OnboardingTextView(text: .privacy)
            ),
            Slide(
                backgroundImage: EuriaResourcesAsset.Images.onboardingBackground3.image,
                backgroundImageTintColor: nil,
                content: .animation(IKLottieConfiguration(
                    id: 3,
                    filename: "padlocks",
                    bundle: EuriaResourcesResources.bundle
                )),
                bottomView: OnboardingTextView(text: .ephemeral)
            ),
            Slide(
                backgroundImage: EuriaResourcesAsset.Images.onboardingBackground4.image,
                backgroundImageTintColor: nil,
                content: .animation(IKLottieConfiguration(
                    id: 4,
                    filename: "cards-transfer-type",
                    bundle: EuriaResourcesResources.bundle
                )),
                bottomView: OnboardingTextView(text: .login)
            )
        ]
    }
}
