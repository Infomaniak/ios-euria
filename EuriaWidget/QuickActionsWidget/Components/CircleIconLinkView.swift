//
//  CircleIconLinkView.swift
//  EuriaWidget
//
//  Created by Valentin Perignon on 05.11.2025.
//

import DesignSystem
import EuriaResources
import InfomaniakCoreSwiftUI
import SwiftUI

struct CircleIconLinkView: View {
    let image: Image
    let url: URL

    var body: some View {
        Link(destination: url) {
            Circle()
                .fill(EuriaResourcesAsset.Colors.widgetButtonColor.swiftUIColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay {
                    image
                        .iconSize(.large)
                }
        }
    }
}
