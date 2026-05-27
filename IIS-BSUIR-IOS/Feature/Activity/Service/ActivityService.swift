//
//  ActivityService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

@MainActor
protocol ActivityServiceProtocol: AnyObject {
    func cachedActivityData() -> ActivityData?
    func fetchActivityData() async throws -> ActivityData
}

@MainActor
final class ActivityService: ActivityServiceProtocol {
    private let apiClient: any APIClient
    private let cache: ProfileCacheService
    private let cacheKey = "activity"

    init(apiClient: any APIClient, cache: ProfileCacheService) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func cachedActivityData() -> ActivityData? {
        cache.load(ActivityData.self, forKey: cacheKey)
    }

    func fetchActivityData() async throws -> ActivityData {
        let dtos: [GradeBookResponseDTO] = try await apiClient.sendRequest(
            path: "/grade-book",
            httpMethod: .GET
        )
        guard let dto = dtos.first else { throw APIError.invalidResponse }
        let data = dto.toActivityData()
        cache.save(data, forKey: cacheKey)
        return data
    }
}

private extension GradeBookResponseDTO {
    func toActivityData() -> ActivityData {
        let entries = student.lessons.compactMap { lesson -> ActivityEntry? in
            guard let subject = lesson.lessonNameAbbrev else { return nil }
            return ActivityEntry(
                id: lesson.id,
                subjectName: subject,
                lessonTypeAbbrev: lesson.lessonTypeAbbrev,
                subGroup: lesson.subGroup,
                marks: lesson.marks ?? [],
                omissions: lesson.gradeBookOmissions ?? 0,
                isRespectfulOmission: lesson.isRespectfulOmission ?? false,
                date: lesson.dateString,
                controlPoint: lesson.controlPoint
            )
        }
        return ActivityData(studentName: student.fio, entries: entries)
    }
}
