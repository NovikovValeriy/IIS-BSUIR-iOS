//
//  LessonDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct LessonDTO: Decodable, Hashable {
    let auditories: [String]?
    let endLessonTime: String
    let lessonTypeAbbrev: String?
    let note: String?
    let numSubgroup: Int
    let startLessonTime: String
    let studentGroups: [LessonStudentGroupDTO]
    let subject: String?
    let subjectFullName: String?
    // null in exam objects
    let weekNumber: [Int]?
    let employees: [ScheduleEmployeeDTO]?
    // "dd.MM.yyyy" — used for exams
    let dateLesson: String?
    let startLessonDate: String?
    let endLessonDate: String?
    let announcement: Bool
    let split: Bool
}

struct LessonStudentGroupDTO: Decodable, Hashable {
    let specialityName: String?
    let specialityCode: String?
    let numberOfStudents: Int?
    let name: String
    let educationDegree: Int
}
