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
import EuriaCore
import EuriaResources
import SwiftUI
import WidgetKit

extension Color {
    static func buttonColor(in renderingMode: WidgetRenderingMode) -> Color {
        let opacity = renderingMode == .fullColor ? 1 : 0.1
        return EuriaResourcesAsset.Colors.widgetButtonColor.swiftUIColor.opacity(opacity)
    }
}

extension View {
    @ViewBuilder
    func containerBackgroundForWidget(color: Color) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(for: .widget) {
                color
            }
        } else {
            background(color)
        }
    }
}

struct QuickActionsWidgetView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemMedium:
            QuickActionsMediumView()
        default:
            QuickActionsSmallView()
        }
    }
}

struct QuickActionsSmallView: View {
    var body: some View {
        VStack(spacing: 0) {
            NewConversationLinkView(url: DeeplinkConstants.newChatURL)

            Spacer(minLength: IKPadding.mini)

            HStack(spacing: 0) {
                CircleIconLinkView(
                    image: EuriaResourcesAsset.Images.camera.swiftUIImage,
                    label: EuriaResourcesStrings.contentDescriptionCamera,
                    url: DeeplinkConstants.cameraURL
                )
                Spacer(minLength: IKPadding.mini)
                CircleIconLinkView(
                    image: EuriaResourcesAsset.Images.microphone.swiftUIImage,
                    label: EuriaResourcesStrings.contentDescriptionMicrophone,
                    url: DeeplinkConstants.speechURL
                )
            }
        }
    }
}

struct QuickActionsMediumView: View {
    var body: some View {
        VStack(spacing: 0) {
            NewConversationLinkView(url: DeeplinkConstants.newChatURL)

            Spacer(minLength: IKPadding.mini)

            HStack(spacing: 0) {
                OvalIconLinkView(
                    image: EuriaResourcesAsset.Images.clockDashed.swiftUIImage,
                    label: EuriaResourcesStrings.contentDescriptionEphemeralChat,
                    url: DeeplinkConstants.ephemeralURL
                )
                Spacer(minLength: IKPadding.mini)
                OvalIconLinkView(
                    image: EuriaResourcesAsset.Images.camera.swiftUIImage,
                    label: EuriaResourcesStrings.contentDescriptionCamera,
                    url: DeeplinkConstants.cameraURL
                )
                Spacer(minLength: IKPadding.mini)
                OvalIconLinkView(
                    image: EuriaResourcesAsset.Images.microphone.swiftUIImage,
                    label: EuriaResourcesStrings.contentDescriptionMicrophone,
                    url: DeeplinkConstants.speechURL
                )
            }
        }
    }
}

struct QuickActionsWidget: Widget {
    static let kind = "\(Constants.bundleId).quickActionsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: QuickActionsProvider()) { _ in
            QuickActionsWidgetView()
                .containerBackgroundForWidget(color: EuriaResourcesAsset.Colors.widgetBackgroundColor.swiftUIColor)
        }
        .configurationDisplayName(EuriaResourcesStrings.widgetQuickActionsTitle)
        .description(EuriaResourcesStrings.widgetQuickActionsDescription)
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@available(iOSApplicationExtension 17.0, *)
#Preview("System Small", as: .systemSmall) {
    QuickActionsWidget()
} timeline: {
    QuickActionsEntry(date: .now)
}

@available(iOSApplicationExtension 17.0, *)
#Preview("System Medium", as: .systemMedium) {
    QuickActionsWidget()
} timeline: {
    QuickActionsEntry(date: .now)
}
