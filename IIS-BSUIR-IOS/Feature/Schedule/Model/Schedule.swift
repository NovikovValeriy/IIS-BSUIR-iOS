//
//  Schedule.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 16.04.26.
//

struct Schedule {
    // Keys are Russian weekday names: "Понедельник", "Вторник", etc.
    let weeklyLessons: [String: [Lesson]]
    let exams: [Lesson]
    // "dd.MM.yyyy" — used to bound the timeline end date
    let semesterEndDate: String?
}
