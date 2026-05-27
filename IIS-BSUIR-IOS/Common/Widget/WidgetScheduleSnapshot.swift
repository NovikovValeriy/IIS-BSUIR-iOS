//
//  WidgetScheduleSnapshot.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

struct WidgetScheduleSnapshot: Codable {
    let subjectName: String
    let lessonsToday: [WidgetLesson]
    let generatedAt: Date
}
