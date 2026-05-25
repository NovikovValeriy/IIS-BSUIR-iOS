//
//  DepartmentTreeNodeDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

struct DepartmentTreeNodeDTO: Decodable {
    let data: DepartmentDataDTO
    let children: [DepartmentTreeNodeDTO]?
}

struct DepartmentDataDTO: Decodable {
    let id: Int
    let name: String
    let abbrev: String
    let urlId: String
}
