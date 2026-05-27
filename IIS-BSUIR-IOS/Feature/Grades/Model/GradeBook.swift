//
//  GradeBook.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 07.05.26.
//

import Foundation

struct GradeBook: Codable {
    let studentName: String
    let subGroup: Int
    // Sorted by date ascending
    let lessons: [GradeBookLesson]
}

struct GradeBookLesson: Codable {
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

struct GradeBookMark {
    let value: Int
    let date: Date?
}

struct GradeBookOmission {
    let count: Int
    let date: Date?
    let isRespectful: Bool
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
    let marks: [GradeBookMark]
    let omissions: [GradeBookOmission]
}

struct GradeBookSubjectSummary {
    struct LessonTypeAverage {
        let abbrev: String
        let average: Double
    }
    let subjectName: String
    let overallAverage: Double?
    let lessonTypeAverages: [LessonTypeAverage]
    let totalOmissionHours: Int
}

extension GradeBookControlPoint {
    var average: Double? {
        let values = subjects.flatMap { $0.marks }.map { $0.value }.filter { $0 > 0 }
        guard !values.isEmpty else { return nil }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    var totalOmissionHours: Int {
        subjects.flatMap { $0.omissions }.reduce(0) { $0 + $1.count }
    }
}
