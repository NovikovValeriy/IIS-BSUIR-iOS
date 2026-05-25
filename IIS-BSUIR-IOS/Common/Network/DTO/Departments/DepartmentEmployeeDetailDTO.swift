//
//  DepartmentEmployeeDetailDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

struct DepartmentEmployeeDetailDTO: Decodable {
    let id: Int
    let firstName: String
    let middleName: String?
    let lastName: String
    let photoLink: String?
    let jobPositions: [DepartmentJobPositionDTO]?
}

struct DepartmentJobPositionDTO: Decodable {
    let jobPosition: String
    let contacts: [DepartmentContactDTO]?
}

struct DepartmentContactDTO: Decodable {
    let phoneNumber: String?
}
