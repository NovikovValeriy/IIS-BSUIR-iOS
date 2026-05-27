//
//  AnnouncementDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

struct AnnouncementDTO: Decodable {
    let id: Int
    let studentGroups: [AnnouncementGroupDTO]?
    let employee: String?
    let startTime: String?
    let endTime: String?
    let content: String?
    let auditory: String?
    // "dd.MM.yyyy"
    let date: String?
    let urlId: String?
    let employeeDepartments: [String]?
}

struct AnnouncementGroupDTO: Decodable {
    let id: Int
    let name: String
    let specialityAbbrev: String?
}
