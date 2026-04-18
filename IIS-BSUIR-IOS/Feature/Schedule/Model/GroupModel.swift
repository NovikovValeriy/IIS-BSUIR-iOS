//
//  GroupModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 16.04.26.
//

struct GroupModel: Hashable, Identifiable, Codable {
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

extension GroupModel {
    static func minimal(name: String) -> GroupModel {
        GroupModel(
            id: 0,
            name: name,
            specialityAbbrev: "",
            specialityName: "",
            facultyAbbrev: "",
            facultyId: 0,
            facultyName: nil,
            course: nil,
            educationDegree: 0,
            calendarId: nil,
            specialityDepartmentEducationFormId: 0
        )
    }
}
