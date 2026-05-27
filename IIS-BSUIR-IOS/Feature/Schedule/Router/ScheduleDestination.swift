//
//  ScheduleDestination.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

enum ScheduleDestination: Hashable {
    case lessonDetail(Lesson, weekday: String?)
    case employeeSchedule(Teacher)
    case groupSchedule(String)
}

enum ScheduleSheet: Identifiable {
    case groupPicker

    var id: String { "\(self)" }
}
