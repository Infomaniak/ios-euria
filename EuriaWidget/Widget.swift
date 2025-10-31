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

struct EuriaWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "EuriaWidget", provider: Provider()) { entry in
            ZStack {
                ContainerRelativeShape().fill(.background)
                Text("Euria")
                    .font(.headline)
                    .padding()
            }
        }
        .configurationDisplayName("Euria")
        .description("Description")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct Entry: TimelineEntry { let date: Date }

@available(iOSApplicationExtension 17.0, *)
#Preview(as: .systemMedium) {
    EuriaWidget()
} timeline: {
    Entry(date: .now)
}
