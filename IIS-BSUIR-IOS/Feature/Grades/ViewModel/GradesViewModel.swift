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
    var selectedControlPointIndex: Int = 0

    // Control points sorted by date ascending
    var controlPoints: [GradeBookControlPoint] {
        guard let gradeBook else { return [] }
        return Self.buildControlPoints(from: gradeBook.lessons)
    }

    var currentControlPoint: GradeBookControlPoint? {
        let points = controlPoints
        guard points.indices.contains(selectedControlPointIndex) else { return nil }
        return points[selectedControlPointIndex]
    }

    private let gradesService: any GradesServiceProtocol

    init(gradesService: any GradesServiceProtocol) {
        self.gradesService = gradesService
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            gradeBook = try await gradesService.fetchGradeBook()
        } catch {
            print(error.localizedDescription)
        }
        selectedControlPointIndex = 0
    }

    // MARK: - Grouping

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
                    marks: subjectLessons.flatMap { $0.marks },
                    totalOmissions: subjectLessons.reduce(0) { $0 + $1.omissions },
                    hasRespectfulOmissions: subjectLessons.contains { $0.isRespectfulOmission }
                )
            }
            .sorted { $0.subjectName < $1.subjectName }
    }
}
