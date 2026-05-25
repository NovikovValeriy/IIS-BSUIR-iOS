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
