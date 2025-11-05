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
    var size: CGFloat = 60
    let image: Image
    let url: URL

    var body: some View {
        Link(destination: url) {
            ZStack {
                Circle()
                    .fill(EuriaResourcesAsset.Colors.disabledPrimary.swiftUIColor)
                    .frame(width: size, height: size)

                image
                    .foregroundStyle(.white)
                    .font(.system(size: IKPadding.large, weight: .semibold))
            }
            .contentShape(Circle())
        }
    }
}

#Preview {
    CircleIconLinkView(image: Image(systemName: "waveform"), url: URL(string: "https://euria.infomaniak.com")!)
}
