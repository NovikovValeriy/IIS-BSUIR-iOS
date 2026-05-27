//
//  Lesson.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 16.04.26.
//

struct Lesson: Hashable, Codable {
    let subject: String?
    let subjectFullName: String?
    let lessonTypeAbbrev: String?
    let startTime: String
    let endTime: String
    let numSubgroup: Int
    let weekNumber: [Int]?
    let auditories: [String]
    let teachers: [Teacher]
    let groups: [LessonGroup]
    let note: String?
    // "dd.MM.yyyy"
    let dateLesson: String?
    let startLessonDate: String?
    let endLessonDate: String?
    let announcement: Bool
    let split: Bool
}
