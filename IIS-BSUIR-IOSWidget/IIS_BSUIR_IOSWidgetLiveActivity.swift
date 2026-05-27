//
//  IIS_BSUIR_IOSWidgetLiveActivity.swift
//  IIS-BSUIR-IOSWidget
//
//  Created by Valery Novikau on 27.05.26.
//

import ActivityKit
import WidgetKit
import SwiftUI
// swiftlint:disable type_name
struct IIS_BSUIR_IOSWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct IIS_BSUIR_IOSWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: IIS_BSUIR_IOSWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension IIS_BSUIR_IOSWidgetAttributes {
    fileprivate static var preview: IIS_BSUIR_IOSWidgetAttributes {
        IIS_BSUIR_IOSWidgetAttributes(name: "World")
    }
}

extension IIS_BSUIR_IOSWidgetAttributes.ContentState {
    fileprivate static var smiley: IIS_BSUIR_IOSWidgetAttributes.ContentState {
        IIS_BSUIR_IOSWidgetAttributes.ContentState(emoji: "😀")
     }

     fileprivate static var starEyes: IIS_BSUIR_IOSWidgetAttributes.ContentState {
         IIS_BSUIR_IOSWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: IIS_BSUIR_IOSWidgetAttributes.preview) {
   IIS_BSUIR_IOSWidgetLiveActivity()
} contentStates: {
    IIS_BSUIR_IOSWidgetAttributes.ContentState.smiley
    IIS_BSUIR_IOSWidgetAttributes.ContentState.starEyes
}
// swiftlint:enable type_name
