//
//  MarkBook.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 21.04.26.
//

struct MarkBook: Codable {
    let number: String
    let averageMark: Double
    // Sorted by semester number ascending
    let semesters: [MarkBookSemester]
}

struct MarkBookSemester: Codable {
    let semester: Int
    let averageMark: Double
    let marks: [Mark]
}

struct Mark: Codable {
    let subject: String
    let formOfControl: String?
    let mark: String?
    let commonMark: Double?
    let commonRetakes: Double?
    let credits: Int?
    let hours: String?
    let teacher: String?
    let date: String?
    let retakesCount: Int
}
