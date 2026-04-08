//
//  EmployeeSearchDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct EmployeeSearchDTO: Decodable {
    let academicDepartment: String
    let fio: String
    let firstName: String
    let id: Int
    let lastName: String
    let middleName: String?
    let price: Double?
}
