//
//  ActivityData.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

struct ActivityData: Codable {
    let studentName: String
    let entries: [ActivityEntry]
}

struct ActivityEntry: Identifiable, Codable {
    let id: Int
    let subjectName: String
    let lessonTypeAbbrev: String?
    let subGroup: Int
    let marks: [Int]
    let omissions: Int
    let isRespectfulOmission: Bool
    let date: String?
    let controlPoint: String?
}
