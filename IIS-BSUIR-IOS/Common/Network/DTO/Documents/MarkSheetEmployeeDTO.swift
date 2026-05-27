//
//  MarkSheetEmployeeDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct MarkSheetEmployeeDTO: Codable {
    let academicDepartment: String?
    let fio: String
    let firstName: String
    let id: Int
    let lastName: String
    let middleName: String?
    let price: Double?
}
