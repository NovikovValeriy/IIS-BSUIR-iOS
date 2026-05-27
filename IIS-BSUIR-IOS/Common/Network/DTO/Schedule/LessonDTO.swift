//
//  LessonDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct LessonDTO: Decodable {
    let auditories: [String]?
    let endLessonTime: String
    let lessonTypeAbbrev: String?
    let note: String?
    let numSubgroup: Int
    let startLessonTime: String
    let studentGroups: [LessonStudentGroupDTO]
    let subject: String?
    let subjectFullName: String?
    let weekNumber: [Int]?
    let employees: [ScheduleEmployeeDTO]?
    // "dd.MM.yyyy"
    let dateLesson: String?
    let startLessonDate: String?
    let endLessonDate: String?
    let announcement: Bool
    let split: Bool
}

struct LessonStudentGroupDTO: Decodable {
    let specialityName: String?
    let specialityCode: String?
    let numberOfStudents: Int?
    let name: String
    let educationDegree: Int
}
