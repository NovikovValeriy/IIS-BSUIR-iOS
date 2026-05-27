//
//  PenaltiesService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

@MainActor
protocol PenaltiesServiceProtocol: AnyObject {
    func cachedRecords() -> [PenaltyIncentiveRecord]?
    func fetchRecords() async throws -> [PenaltyIncentiveRecord]
}

@MainActor
final class PenaltiesService: PenaltiesServiceProtocol {
    private let apiClient: any APIClient
    private let cache: ProfileCacheService
    private let cacheKey = "penalties"

    init(apiClient: any APIClient, cache: ProfileCacheService) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func cachedRecords() -> [PenaltyIncentiveRecord]? {
        cache.load([PenaltyIncentiveRecord].self, forKey: cacheKey)
    }

    func fetchRecords() async throws -> [PenaltyIncentiveRecord] {
        let dtos: [PenaltyIncentiveDTO] = try await apiClient.sendRequest(
            path: "/dormitory-queue-application/premium-penalty",
            httpMethod: .GET
        )
        let records = dtos.map { $0.toDomain() }
        cache.save(records, forKey: cacheKey)
        return records
    }
}

private extension PenaltyIncentiveDTO {
    func toDomain() -> PenaltyIncentiveRecord {
        PenaltyIncentiveRecord(
            id: id,
            isPenalty: directiveDto.eventTypeName.uppercased().contains("PENALTY"),
            eventTypeName: directiveDto.typeName,
            directiveNumber: directiveDto.number,
            date: directiveDto.date,
            status: status,
            note: note,
            reason: reason
        )
    }
}
