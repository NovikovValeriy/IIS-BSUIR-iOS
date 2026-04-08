//
//  DormitoryPrivilegeDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct DormitoryPrivilegeDTO: Decodable {
    let dormitoryPrivilegeCategoryId: Int
    let dormitoryPrivilegeCategoryName: String
    let dormitoryPrivilegeId: Int
    let dormitoryPrivilegeName: String
    let id: Int
    let note: String?
    let studentId: Int
    let year: Int
}
