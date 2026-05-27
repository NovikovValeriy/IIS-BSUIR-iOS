//
//  Announcement.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

struct Announcement: Identifiable, Codable {
    let id: Int
    let employee: String?
    let startTime: String?
    let endTime: String?
    let content: String?
    let auditory: String?
    let date: String?
    let departments: [String]
    let groups: [String]
}
