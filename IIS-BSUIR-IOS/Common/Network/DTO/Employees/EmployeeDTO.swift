//
//  EmployeeDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct EmployeeDTO: Decodable {
    let academicDepartment: [String]
    let calendarId: String?
    let degree: String?
    let fio: String
    let firstName: String
    let id: Int
    let lastName: String
    let middleName: String?
    let photoLink: String?
    let rank: String?
    let urlId: String
}
