//
//  StudentGroupDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct StudentGroupDTO: Decodable {
    let calendarId: String?
    let course: Int?
    let educationDegree: Int
    let facultyAbbrev: String
    let facultyId: Int
    let facultyName: String?
    let id: Int
    let name: String
    let specialityAbbrev: String
    let specialityDepartmentEducationFormId: Int
    let specialityName: String
}
