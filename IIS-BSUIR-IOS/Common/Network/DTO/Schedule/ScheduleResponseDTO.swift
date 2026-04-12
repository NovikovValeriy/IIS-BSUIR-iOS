//
//  ScheduleResponseDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct ScheduleResponseDTO: Decodable {
    let currentPeriod: String?
    let currentTerm: String?
    let startDate: String?
    let endDate: String?
    let startExamsDate: String?
    let endExamsDate: String?
    let employeeDto: ScheduleEmployeeDTO?
    let studentGroupDto: ScheduleStudentGroupDTO?
    // Keys are Russian weekday names: "Понедельник", "Вторник", etc.
    let schedules: [String: [LessonDTO]]?
    let previousSchedules: [String: [LessonDTO]]?
    let nextSchedules: [String: [LessonDTO]]?
    let exams: [LessonDTO]?
}
