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

import InfomaniakOnboarding
import Lottie
import SwiftUI

struct WaveView<BottomView: View>: UIViewControllerRepresentable {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedSlide: Int

    let slides: [Slide]

    let shouldAnimateBottomViewForIndex: (Int) -> Bool
    @ViewBuilder var bottomView: (Int) -> BottomView

    init(
        slides: [Slide],
        selectedSlide: Binding<Int>,
        shouldAnimateBottomViewForIndex: @escaping (Int) -> Bool = { _ in return false },
        @ViewBuilder bottomView: @escaping (Int) -> BottomView
    ) {
        self.slides = slides
        _selectedSlide = selectedSlide
        self.shouldAnimateBottomViewForIndex = shouldAnimateBottomViewForIndex
        self.bottomView = bottomView
    }

    func makeUIViewController(context: Context) -> OnboardingViewController {
        let configuration = OnboardingConfiguration(
            headerImage: nil,
            slides: slides,
            pageIndicatorColor: .blue,
            isScrollEnabled: true,
            dismissHandler: nil,
            isPageIndicatorHidden: false
        )

        let controller = OnboardingViewController(configuration: configuration)
        controller.delegate = context.coordinator

        return controller
    }

    func updateUIViewController(_ uiViewController: OnboardingViewController, context: Context) {
        if uiViewController.pageIndicator.currentPage != selectedSlide {
            uiViewController.setSelectedSlide(index: selectedSlide)
        }

        if colorScheme != context.coordinator.currentColorScheme,
           let currentSlideViewCell = uiViewController.currentSlideViewCell {
            context.coordinator.currentColorScheme = colorScheme
            context.coordinator.selectCorrectAnimation(for: currentSlideViewCell, at: selectedSlide)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(
            parent: self,
            colorScheme: colorScheme,
            shouldAnimateBottomViewForIndex: shouldAnimateBottomViewForIndex
        )
    }

    class Coordinator: OnboardingViewControllerDelegate {
        let parent: WaveView<BottomView>
        var currentColorScheme: ColorScheme

        let shouldAnimateBottomViewForIndex: (Int) -> Bool

        init(
            parent: WaveView<BottomView>,
            colorScheme: ColorScheme,
            shouldAnimateBottomViewForIndex: @escaping (Int) -> Bool,
        ) {
            self.parent = parent
            currentColorScheme = colorScheme
            self.shouldAnimateBottomViewForIndex = shouldAnimateBottomViewForIndex
        }

        func bottomViewForIndex(_ index: Int) -> (any View)? {
            return parent.bottomView(index)
        }

        func currentIndexChanged(newIndex: Int) {
            Task { @MainActor in
                parent.$selectedSlide.wrappedValue = newIndex
            }
        }

        func shouldAnimateBottomViewForIndex(_ index: Int) -> Bool {
            return shouldAnimateBottomViewForIndex(index)
        }

        func willDisplaySlideViewCell(_ slideViewCell: SlideCollectionViewCell, at index: Int) {
            selectCorrectAnimation(for: slideViewCell, at: index)
        }

        func selectCorrectAnimation(for slideViewCell: SlideCollectionViewCell, at index: Int) {
            guard case .animation(let configuration) = parent.slides[index].content else { return }

            let themedFileName = getAnimation(for: index)
            let animation = LottieAnimation.named(themedFileName, bundle: configuration.bundle)

            slideViewCell.illustrationAnimationView.animation = animation
            slideViewCell.illustrationAnimationView.play()
        }

        private func getAnimation(for index: Int) -> String {
            switch index {
            case 1:
                return ThemedAnimation.onboardingPrivacy.animationName(for: currentColorScheme)
            case 2:
                return ThemedAnimation.onboardingEphemeral.animationName(for: currentColorScheme)
            default:
                return ThemedAnimation.onboardingEuria.animationName(for: currentColorScheme)
            }
        }
    }
}
