//
//  OmissionsService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 28.05.26.
//

import Foundation

@MainActor
protocol OmissionsServiceProtocol: AnyObject {
    func cachedOmissions() -> OmissionsData?
    func fetchOmissions() async throws -> OmissionsData
}

@MainActor
final class OmissionsService: OmissionsServiceProtocol {
    private let apiClient: any APIClient
    private let cache: ProfileCacheService
    private let cacheKey = "omissions"

    init(apiClient: any APIClient, cache: ProfileCacheService) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func cachedOmissions() -> OmissionsData? {
        cache.load(OmissionsData.self, forKey: cacheKey)
    }

    func fetchOmissions() async throws -> OmissionsData {
        async let documentDTO: OmissionsResponseDTO = apiClient.sendRequest(
            path: "/omissions-by-student",
            httpMethod: .GET
        )
        async let applicationDTOs: [OmissionApplicationDTO] = apiClient.sendRequest(
            path: "/omissions-by-student-application",
            httpMethod: .GET
        )
        async let countDTOs: [OmissionCountDTO] = apiClient.sendRequest(
            path: "/omission-count-by-student-for-semester",
            httpMethod: .GET
        )
        let (docs, apps, counts) = try await (documentDTO, applicationDTOs, countDTOs)
        let data = OmissionsData(
            faculty: docs.faculty ?? "",
            documents: (docs.omissionDtoList ?? []).map { $0.toDomain() },
            applications: apps.map { $0.toDomain() },
            semesterCounts: counts.map { OmissionSemesterCount(term: $0.term, totalHours: $0.totalHours) }
        )
        cache.save(data, forKey: cacheKey)
        return data
    }
}

private extension OmissionDTO {
    func toDomain() -> OmissionDocument {
        OmissionDocument(
            id: id,
            name: name,
            dateFrom: Self.formatDate(dateFrom),
            dateTo: Self.formatDate(dateTo),
            note: note,
            term: term
        )
    }
}

private extension OmissionApplicationDTO {
    func toDomain() -> OmissionApplication {
        OmissionApplication(
            id: id,
            number: number,
            status: status,
            type: omissionCertificateType,
            dateFrom: Self.formatDate(dateFrom),
            dateTo: Self.formatDate(dateTo),
            createdDate: Self.formatDateTime(createdDate),
            placeOfStay: placeOfStay,
            rejectionReason: rejectionReason
        )
    }
}

private extension OmissionDTO {
    static func formatDate(_ value: String) -> String {
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd"
        let output = DateFormatter()
        output.dateStyle = .medium
        output.timeStyle = .none
        if let date = input.date(from: value) { return output.string(from: date) }
        return value
    }
}

private extension OmissionApplicationDTO {
    static func formatDate(_ value: String) -> String {
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd"
        let output = DateFormatter()
        output.dateStyle = .medium
        output.timeStyle = .none
        if let date = input.date(from: value) { return output.string(from: date) }
        return value
    }

    static func formatDateTime(_ value: String) -> String {
        let input = ISO8601DateFormatter()
        input.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime, .withDashSeparatorInDate]
        let output = DateFormatter()
        output.dateStyle = .medium
        output.timeStyle = .none
        if let date = input.date(from: value) { return output.string(from: date) }
        return String(value.prefix(10))
    }
}
