//
//  ScheduleDestination.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

enum ScheduleDestination: Hashable {
    case lessonDetail(LessonDTO)
    case employeeSchedule(employeeId: String)
    case groupSchedule(groupId: String)
}

enum ScheduleSheet: Identifiable {
    case filterOptions
    case weekPicker

    var id: String { "\(self)" }
}
