//
//  GradesService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 21.04.26.
//

import Foundation

@MainActor
protocol GradesServiceProtocol: AnyObject {
    func fetchMarkBook() async throws -> MarkBook
}

@MainActor
final class GradesService: GradesServiceProtocol {
    private let apiClient: any APIClient

    init(apiClient: any APIClient) {
        self.apiClient = apiClient
    }

    func fetchMarkBook() async throws -> MarkBook {
        let dto: MarkBookResponseDTO = try await apiClient.sendRequest(path: "/markbook", httpMethod: .GET)
        return dto.toDomain()
    }
}

// MARK: - Mapping

private extension MarkBookResponseDTO {
    func toDomain() -> MarkBook {
        let semesters = markPages
            .compactMap { key, page -> MarkBookSemester? in
                guard let semester = Int(key) else { return nil }
                return page.toDomain(semester: semester)
            }
            .sorted { $0.semester < $1.semester }
        return MarkBook(number: number, averageMark: averageMark, semesters: semesters)
    }
}

private extension MarkBookPageDTO {
    func toDomain(semester: Int) -> MarkBookSemester {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        let sorted = marks.map { $0.toDomain() }.sorted { lhs, rhs in
            switch (lhs.date.flatMap { dateFormatter.date(from: $0) },
                    rhs.date.flatMap { dateFormatter.date(from: $0) }) {
            case (nil, nil): return lhs.subject < rhs.subject
            case (nil, _):   return true
            case (_, nil):   return false
            case let (left?, right?): return left < right
            }
        }

        return MarkBookSemester(semester: semester, averageMark: averageMark, marks: sorted)
    }
}

private extension MarkDTO {
    func toDomain() -> Mark {
        Mark(
            subject: fullSubject ?? subject ?? "",
            formOfControl: formOfControl,
            mark: mark,
            commonMark: commonMark,
            commonRetakes: commonRetakes.map { $0 * 100 },
            credits: credits,
            hours: hours,
            teacher: teacher,
            date: date,
            retakesCount: retakesCount ?? 0
        )
    }
}
