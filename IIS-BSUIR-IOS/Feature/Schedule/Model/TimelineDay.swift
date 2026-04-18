//
//  TimelineDay.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 14.04.26.
//

import Foundation

struct TimelineDay: Identifiable {
    /// Normalized to start of day in the current calendar.
    let date: Date
    let lessons: [Lesson]
    /// 4-week cycle position (1–4) for this day. Nil if the current semester week is not yet known.
    let cycleWeek: Int?

    var id: Date { date }
}
