//
//  NewConversationLinkView.swift
//  EuriaWidget
//
//  Created by Valentin Perignon on 05.11.2025.
//

import DesignSystem
import EuriaResources
import SwiftUI

struct NewConversationLinkView: View {
    let url: URL

    var body: some View {
        Link(destination: url) {
            EuriaResourcesAsset.Images.widgetEuria.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: IKIconSize.large.rawValue, height: IKIconSize.large.rawValue)
                .padding(.horizontal, IKPadding.medium)
                .padding(.vertical, IKPadding.small)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: Alignment(horizontal: .leading, vertical: .center))
                .background(
                    Capsule()
                        .fill(EuriaResourcesAsset.Colors.disabledPrimary.swiftUIColor)
                )
        }
    }
}
