//
//  GradeBook.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 07.05.26.
//

import Foundation

struct GradeBook {
    let studentName: String
    let subGroup: Int
    // Sorted by date ascending
    let lessons: [GradeBookLesson]
}

struct GradeBookLesson {
    let id: Int
    let subjectName: String
    let lessonTypeAbbrev: String?
    let subGroup: Int
    let marks: [Int]
    let omissions: Int
    let isRespectfulOmission: Bool
    let date: Date?
    let controlPointDate: Date?
    let controlPointString: String
}

struct GradeBookControlPoint {
    let date: Date
    let displayString: String
    let subjects: [GradeBookSubjectGroup]
}

struct GradeBookSubjectGroup {
    let subjectName: String
    let lessonTypeAbbrev: String?
    let subGroup: Int
    let marks: [Int]
    let totalOmissions: Int
    let hasRespectfulOmissions: Bool
}

extension GradeBookControlPoint {
    var average: Double? {
        let marks = subjects.flatMap { $0.marks }.filter { $0 > 0 }
        guard !marks.isEmpty else { return nil }
        return Double(marks.reduce(0, +)) / Double(marks.count)
    }
}
