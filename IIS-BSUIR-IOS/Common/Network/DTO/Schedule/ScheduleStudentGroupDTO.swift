//
//  ScheduleStudentGroupDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct ScheduleStudentGroupDTO: Decodable {
    let name: String
    let facultyId: Int
    let facultyAbbrev: String
    let specialityDepartmentEducationFormId: Int
    let specialityName: String
    let specialityAbbrev: String
    let course: Int
    let id: Int
    let calendarId: String?
    let educationDegree: Int
}
