//
//  Department.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

struct Department: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let abbrev: String
    let urlId: String
}

struct DepartmentNode: Identifiable, Codable {
    let number: String
    let department: Department
    let employeeCount: Int
    let children: [DepartmentNode]
    var id: Int { department.id }
    var hasChildren: Bool { !children.isEmpty }
    var hasEmployees: Bool { employeeCount > 0 }
}
