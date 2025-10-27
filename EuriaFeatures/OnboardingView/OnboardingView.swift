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

import EuriaCore
import EuriaCoreUI
import InfomaniakCoreUIResources
import InfomaniakDI
import InfomaniakOnboarding
import SwiftUI

public struct OnboardingView: View {
    @State private var loginHandler = LoginHandler()
    @State private var selectedSlideIndex = 0

    private let slides = Slide.onboardingSlides

    public init() {}

    public var body: some View {
        WaveView(slides: slides, selectedSlide: $selectedSlideIndex) { slideIndex in
            slideIndex == slides.count - 1 || (slideIndex == slides.count - 2 && selectedSlideIndex == slides.count - 1)
        } bottomView: { _ in
            OnboardingBottomButtonsView(loginHandler: loginHandler, selection: $selectedSlideIndex, slideCount: slides.count)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    OnboardingView()
}
