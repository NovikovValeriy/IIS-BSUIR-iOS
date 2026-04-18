//
//  ScheduleEmployeeDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct ScheduleEmployeeDTO: Decodable {
    let id: Int
    let firstName: String
    let middleName: String?
    let lastName: String
    let photoLink: String?
    let degree: String?
    let degreeAbbrev: String?
    let rank: String?
    let email: String?
    let urlId: String
    let calendarId: String?
    let jobPositions: String?
}
