//
//  LessonGroup.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 16.04.26.
//

struct LessonGroup: Hashable, Codable {
    let name: String
    let specialityName: String?
    let specialityCode: String?
    let numberOfStudents: Int?
    let educationDegree: Int
}
