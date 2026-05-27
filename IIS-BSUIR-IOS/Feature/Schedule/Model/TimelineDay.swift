//
//  TimelineDay.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 14.04.26.
//

import Foundation

struct TimelineDay: Identifiable {
    let date: Date
    let lessons: [Lesson]
    let cycleWeek: Int?

    var id: Date { date }
}
