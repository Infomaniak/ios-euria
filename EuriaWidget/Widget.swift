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
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry { Entry(date: .now) }
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        completion(Entry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        completion(Timeline(entries: [Entry(date: .now)], policy: .atEnd))
    }
}

private struct SearchLinkBar: View {
    var url: URL

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 8) {
                EuriaResourcesAsset.Images.widgetEuria.swiftUIImage
                    .resizable()
                    .scaledToFit()

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(.thinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(.quaternary, lineWidth: 0)
            )
        }
    }
}

private struct CircleIcon: View {
    var size: CGFloat = 40
    var symbolColor: Color = .primary
    var borderWidth: CGFloat = 1
    var image: Image

    init(image: Image) {
        self.image = image
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(.blue)

            image
                .resizable()
                .scaledToFit()
                .foregroundStyle(symbolColor)
                .padding(size * 0.28)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct widgetEntryView: View {
    private let searchURL = URL(string: "euria://search")!

    var body: some View {
        VStack(spacing: 12) {
            SearchLinkBar(url: searchURL)

            HStack {
                CircleIcon(image: Image(systemName: "clock"))
                Spacer()
                CircleIcon(image: Image(systemName:"star"))

            }
        }
        .padding(8)
    }
}

struct EuriaWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "EuriaWidget", provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                widgetEntryView()
                    .containerBackground(for: .widget) {}
            } else {
                widgetEntryView()
            }
        }
        .configurationDisplayName("Euria")
        .description("Description")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct Entry: TimelineEntry { let date: Date }

@available(iOSApplicationExtension 17.0, *)
#Preview(as: .systemSmall) {
    EuriaWidget()
} timeline: {
    Entry(date: .now)
}
