//
//  Discipline.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 26.05.26.
//

struct Discipline: Identifiable, Codable {
    var id: String { name }
    let name: String
    let hours: Int
}
