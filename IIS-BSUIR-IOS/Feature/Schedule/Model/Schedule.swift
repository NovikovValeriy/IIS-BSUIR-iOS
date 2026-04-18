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
    // "dd.MM.yyyy" dates bounding the semester and exam periods
    let semesterEndDate: String?
    let examsStartDate: String?
    let examsEndDate: String?
}
