//
//  AnnouncementsService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

@MainActor
protocol AnnouncementsServiceProtocol: AnyObject {
    func cachedAnnouncements() -> [Announcement]?
    func fetchAnnouncements() async throws -> [Announcement]
}

@MainActor
final class AnnouncementsService: AnnouncementsServiceProtocol {
    private let apiClient: any APIClient
    private let cache: ProfileCacheService
    private let cacheKey = "announcements"

    init(apiClient: any APIClient, cache: ProfileCacheService) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func cachedAnnouncements() -> [Announcement]? {
        cache.load([Announcement].self, forKey: cacheKey)
    }

    func fetchAnnouncements() async throws -> [Announcement] {
        let dtos: [AnnouncementDTO] = try await apiClient.sendRequest(
            path: "/announcements",
            httpMethod: .GET
        )
        let announcements = dtos.map { $0.toDomain() }
        cache.save(announcements, forKey: cacheKey)
        return announcements
    }
}

private extension AnnouncementDTO {
    func toDomain() -> Announcement {
        Announcement(
            id: id,
            employee: employee,
            startTime: startTime,
            endTime: endTime,
            content: content,
            auditory: auditory,
            date: date,
            departments: employeeDepartments ?? [],
            groups: studentGroups?.map { $0.name } ?? []
        )
    }
}
