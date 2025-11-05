//
//  CircleIconLinkView.swift
//  EuriaWidget
//
//  Created by Valentin Perignon on 05.11.2025.
//

import DesignSystem
import EuriaResources
import SwiftUI

struct CircleIconLinkView: View {
    let image: Image
    let url: URL

    var body: some View {
        Link(destination: url) {
            Circle()
                .fill(EuriaResourcesAsset.Colors.disabledPrimary.swiftUIColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay {
                    image
                        .foregroundStyle(.white)
                        .font(.system(size: IKIconSize.large.rawValue, weight: .semibold))
                }
        }
    }
}
