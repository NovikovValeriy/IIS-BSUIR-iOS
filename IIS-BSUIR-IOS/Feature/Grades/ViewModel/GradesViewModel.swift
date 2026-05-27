//
//  GradesViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 07.05.26.
//

import Foundation

@Observable
@MainActor
final class GradesViewModel {
    private(set) var gradeBook: GradeBook?
    private(set) var isLoading: Bool = false
    var selectedTabIndex: Int = 0

    var controlPoints: [GradeBookControlPoint] {
        guard let gradeBook else { return [] }
        return Self.buildControlPoints(from: gradeBook.lessons)
    }

    var overallAverage: Double? {
        guard let gradeBook else { return nil }
        let marks = gradeBook.lessons.flatMap { $0.marks }.filter { $0 > 0 }
        guard !marks.isEmpty else { return nil }
        return Double(marks.reduce(0, +)) / Double(marks.count)
    }

    var overallOmissionHours: Int {
        subjectSummaries.reduce(0) { $0 + $1.totalOmissionHours }
    }

    var subjectSummaries: [GradeBookSubjectSummary] {
        guard let gradeBook else { return [] }

        var bySubject: [String: [GradeBookLesson]] = [:]
        var subjectOrder: [String] = []
        for lesson in gradeBook.lessons {
            if bySubject[lesson.subjectName] == nil { subjectOrder.append(lesson.subjectName) }
            bySubject[lesson.subjectName, default: []].append(lesson)
        }

        return subjectOrder.compactMap { name -> GradeBookSubjectSummary? in
            let lessons = bySubject[name]!
            let nonZeroMarks = lessons.flatMap { $0.marks }.filter { $0 > 0 }
            let totalOmissions = lessons.reduce(0) { $0 + $1.omissions }
            guard !nonZeroMarks.isEmpty || totalOmissions > 0 else { return nil }

            let overallAverage: Double? = nonZeroMarks.isEmpty ? nil :
                Double(nonZeroMarks.reduce(0, +)) / Double(nonZeroMarks.count)

            var marksByType: [String: [Int]] = [:]
            for lesson in lessons {
                guard let type = lesson.lessonTypeAbbrev else { continue }
                marksByType[type, default: []].append(contentsOf: lesson.marks.filter { $0 > 0 })
            }
            let lessonTypeAverages = Self
                .lessonTypeOrder
                .compactMap { type -> GradeBookSubjectSummary.LessonTypeAverage? in
                    guard let marks = marksByType[type], !marks.isEmpty else { return nil }
                    return GradeBookSubjectSummary.LessonTypeAverage(
                        abbrev: type,
                        average: Double(marks.reduce(0, +)) / Double(marks.count)
                    )
                }

            return GradeBookSubjectSummary(
                subjectName: name,
                overallAverage: overallAverage,
                lessonTypeAverages: lessonTypeAverages,
                totalOmissionHours: totalOmissions
            )
        }
    }

    private let gradesService: any GradesServiceProtocol

    init(gradesService: any GradesServiceProtocol) {
        self.gradesService = gradesService
        self.gradeBook = gradesService.cachedGradeBook()
    }

    func load() async {
        guard !isLoading else { return }
        if gradeBook == nil {
            isLoading = true
        }
        defer { isLoading = false }
        do {
            gradeBook = try await gradesService.fetchGradeBook()
        } catch {
            print(error.localizedDescription)
        }
        selectedTabIndex = 0
    }

    // MARK: - Grouping

    private static let lessonTypeOrder = ["ЛК", "ПЗ", "ЛР"]

    private static func buildControlPoints(from lessons: [GradeBookLesson]) -> [GradeBookControlPoint] {
        var lessonsByControlPoint: [String: [GradeBookLesson]] = [:]
        var dateByControlPointString: [String: Date] = [:]
        var outsideLessons: [GradeBookLesson] = []

        for lesson in lessons {
            let key = lesson.controlPointString
            guard let date = lesson.controlPointDate else {
                outsideLessons.append(lesson)
                continue
            }
            lessonsByControlPoint[key, default: []].append(lesson)
            dateByControlPointString[key] = date
        }

        var points = lessonsByControlPoint
            .compactMap { key, pointLessons -> GradeBookControlPoint? in
                guard let date = dateByControlPointString[key] else { return nil }
                return GradeBookControlPoint(
                    date: date,
                    displayString: key,
                    subjects: buildSubjectGroups(from: pointLessons)
                )
            }
            .sorted { $0.date < $1.date }

        if !outsideLessons.isEmpty {
            points.append(GradeBookControlPoint(
                date: .distantFuture,
                displayString: "Вне КТ",
                subjects: buildSubjectGroups(from: outsideLessons)
            ))
        }

        return points
    }

    private static func buildSubjectGroups(from lessons: [GradeBookLesson]) -> [GradeBookSubjectGroup] {
        var lessonsBySubject: [String: [GradeBookLesson]] = [:]

        for lesson in lessons {
            let key = "\(lesson.subjectName)-\(lesson.lessonTypeAbbrev ?? "")"
            lessonsBySubject[key, default: []].append(lesson)
        }

        return lessonsBySubject
            .map { _, subjectLessons -> GradeBookSubjectGroup in
                let first = subjectLessons[0]
                return GradeBookSubjectGroup(
                    subjectName: first.subjectName,
                    lessonTypeAbbrev: first.lessonTypeAbbrev,
                    subGroup: first.subGroup,
                    marks: subjectLessons.flatMap { lesson in
                        lesson.marks.map { GradeBookMark(value: $0, date: lesson.date) }
                    },
                    omissions: subjectLessons.compactMap { lesson in
                        guard lesson.omissions > 0 else { return nil }
                        return GradeBookOmission(
                            count: lesson.omissions,
                            date: lesson.date,
                            isRespectful: lesson.isRespectfulOmission
                        )
                    }
                )
            }
            .sorted { $0.subjectName < $1.subjectName }
    }
}
