//
//  GroupModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 16.04.26.
//

struct GroupModel: Hashable, Identifiable {
    let id: Int
    let name: String
    let specialityAbbrev: String
    let specialityName: String
    let facultyAbbrev: String
    let facultyId: Int
    let facultyName: String?
    let course: Int?
    let educationDegree: Int
    let calendarId: String?
    let specialityDepartmentEducationFormId: Int
}
