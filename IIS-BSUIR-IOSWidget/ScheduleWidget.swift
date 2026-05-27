//
//  ScheduleWidget.swift
//  IIS-BSUIR-IOSWidget
//
//  Created by Valery Novikau on 27.05.26.
//

import WidgetKit
import SwiftUI

struct ScheduleWidget: Widget {
    let kind: String = "ScheduleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ScheduleTimelineProvider()) { entry in
            ScheduleWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("widget.display_name")
        .description("widget.description")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct ScheduleWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ScheduleEntry

    var body: some View {
        switch family {
        case .systemSmall:
            WidgetSmallView(entry: entry)
        case .systemMedium:
            WidgetMediumView(entry: entry)
        case .systemLarge:
            WidgetLargeView(entry: entry)
        default:
            WidgetSmallView(entry: entry)
        }
    }
}
