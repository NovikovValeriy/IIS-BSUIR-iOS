//
//  ScheduledLessonNotification.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

struct ScheduledLessonNotification: Identifiable {
    let id: String
    let title: String
    let body: String
    let triggerTime: String
    let isWeekly: Bool
}
