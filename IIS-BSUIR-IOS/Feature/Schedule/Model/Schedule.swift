//
//  Schedule.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 16.04.26.
//

struct Schedule: Codable, Equatable {
    let weeklyLessons: [String: [Lesson]]
    let exams: [Lesson]
    // "dd.MM.yyyy"
    let semesterEndDate: String?
    let examsStartDate: String?
    let examsEndDate: String?
}
