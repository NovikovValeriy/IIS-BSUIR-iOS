//
//  DepartmentEmployee.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

struct DepartmentEmployee: Identifiable, Codable {
    let id: Int
    let fio: String
    let photoLink: String?
    let jobPosition: String?
    let phones: [String]
}
