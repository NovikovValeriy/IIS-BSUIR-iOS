//
//  DormitoryService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

@MainActor
protocol DormitoryServiceProtocol: AnyObject {
    func cachedDormitoryData() -> DormitoryData?
    func fetchDormitoryData() async throws -> DormitoryData
}

@MainActor
final class DormitoryService: DormitoryServiceProtocol {
    private let apiClient: any APIClient
    private let cache: ProfileCacheService
    private let cacheKey = "dormitory"

    init(apiClient: any APIClient, cache: ProfileCacheService) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func cachedDormitoryData() -> DormitoryData? {
        cache.load(DormitoryData.self, forKey: cacheKey)
    }

    func fetchDormitoryData() async throws -> DormitoryData {
        async let applicationDTOs: [DormitoryApplicationDTO] = apiClient.sendRequest(
            path: "/dormitory-queue-application",
            httpMethod: .GET
        )
        async let privilegeDTOs: [DormitoryPrivilegeDTO] = apiClient.sendRequest(
            path: "/dormitory-queue-application/privileges",
            httpMethod: .GET
        )
        let (apps, privs) = try await (applicationDTOs, privilegeDTOs)
        let data = DormitoryData(
            applications: apps.map { $0.toDomain() },
            privileges: privs.map { $0.toDomain() }
        )
        cache.save(data, forKey: cacheKey)
        return data
    }
}

private extension DormitoryApplicationDTO {
    func toDomain() -> DormitoryApplication {
        DormitoryApplication(
            id: id,
            number: number,
            numberInQueue: numberInQueue,
            status: status,
            roomInfo: roomInfo,
            applicationDate: Self.formatISODate(applicationDate),
            acceptedDate: Self.formatISODate(acceptedDate),
            settledDate: Self.formatISODate(settledDate),
            rejectionReason: rejectionReason
        )
    }

    private static func formatISODate(_ value: String?) -> String? {
        guard let value else { return nil }
        let display = DateFormatter()
        display.dateStyle = .medium
        display.timeStyle = .none
        // "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: value) { return display.string(from: date) }
        // fallback: strip time component
        return String(value.prefix(10))
    }
}

private extension DormitoryPrivilegeDTO {
    func toDomain() -> DormitoryPrivilege {
        DormitoryPrivilege(
            id: id,
            categoryName: dormitoryPrivilegeCategoryName,
            privilegeName: dormitoryPrivilegeName,
            note: note,
            year: year
        )
    }
}
