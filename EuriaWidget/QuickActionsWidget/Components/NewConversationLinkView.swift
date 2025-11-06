//
//  NewConversationLinkView.swift
//  EuriaWidget
//
//  Created by Valentin Perignon on 05.11.2025.
//

import DesignSystem
import EuriaResources
import SwiftUI
import EuriaCore

extension Image {
    @ViewBuilder
    func widgetFullColorRenderingMode() -> some View {
        if #available(iOS 26.0, *) {
            widgetAccentedRenderingMode(.fullColor)
        } else {
            self
        }
    }
}

struct NewConversationLinkView: View {
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode

    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 4) {
                EuriaResourcesAsset.Images.euriaLogo.swiftUIImage
                    .resizable()
                    .widgetFullColorRenderingMode()
                    .scaledToFit()

                Text("Euria")
                    .fontWeight(.bold)
                    .foregroundStyle(EuriaResourcesAsset.Colors.widgetTextPrimaryColor.swiftUIColor)
                    .minimumScaleFactor(0.5)
            }
            .padding(IKPadding.small)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background {
                Capsule()
                    .fill(Color.buttonColor(in: widgetRenderingMode))
            }
        }
    }
}
