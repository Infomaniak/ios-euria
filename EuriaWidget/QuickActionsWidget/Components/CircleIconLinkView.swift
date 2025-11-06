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
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode

    let image: Image
    let url: URL

    var body: some View {
        Link(destination: url) {
            Circle()
                .fill(Color.buttonColor(in: widgetRenderingMode))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay {
                    image
                        .iconSize(.large)
                }
        }
    }
}
