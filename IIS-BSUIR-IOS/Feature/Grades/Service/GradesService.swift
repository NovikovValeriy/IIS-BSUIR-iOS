//
//  GradesService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 07.05.26.
//

import Foundation

@MainActor
protocol GradesServiceProtocol: AnyObject {
    func fetchGradeBook() async throws -> GradeBook
}

@MainActor
final class GradesService: GradesServiceProtocol {
    private let apiClient: any APIClient

    init(apiClient: any APIClient) {
        self.apiClient = apiClient
    }

    func fetchGradeBook() async throws -> GradeBook {
        let dtos: [GradeBookResponseDTO] = try await apiClient.sendRequest(path: "/grade-book", httpMethod: .GET)
        guard let dto = dtos.first else { throw APIError.invalidResponse }
        return dto.toDomain()
    }
}

// MARK: - Mapping

extension GradeBookResponseDTO {
    func toDomain() -> GradeBook {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        let lessons = student.lessons
            .compactMap { lessonDTO -> GradeBookLesson? in
                guard let subjectName = lessonDTO.lessonNameAbbrev else { return nil }
                return GradeBookLesson(
                    id: lessonDTO.id,
                    subjectName: subjectName,
                    lessonTypeAbbrev: lessonDTO.lessonTypeAbbrev,
                    subGroup: lessonDTO.subGroup,
                    marks: lessonDTO.marks ?? [],
                    omissions: lessonDTO.gradeBookOmissions ?? 0,
                    isRespectfulOmission: lessonDTO.isRespectfulOmission ?? false,
                    date: lessonDTO.dateString.flatMap { dateFormatter.date(from: $0) },
                    controlPointDate: lessonDTO.controlPoint.flatMap { dateFormatter.date(from: $0) },
                    controlPointString: lessonDTO.controlPoint ?? ""
                )
            }
            .sorted { lhs, rhs in
                switch (lhs.date, rhs.date) {
                case (nil, nil): return lhs.subjectName < rhs.subjectName
                case (nil, _): return true
                case (_, nil): return false
                case let (lhs?, rhs?): return lhs < rhs
                }
            }

        return GradeBook(
            studentName: student.fio,
            subGroup: student.subGroup,
            lessons: lessons
        )
    }
}
