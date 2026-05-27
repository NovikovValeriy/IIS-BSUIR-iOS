//
//  DocumentsService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

@MainActor
protocol DocumentsServiceProtocol: AnyObject {
    func cachedCertificates() -> [Certificate]?
    func fetchCertificates() async throws -> [Certificate]
    func cachedMarkSheets() -> [MarkSheet]?
    func fetchMarkSheets() async throws -> [MarkSheet]
}

@MainActor
final class DocumentsService: DocumentsServiceProtocol {
    private let apiClient: any APIClient
    private let cache: ProfileCacheService
    private let certificatesCacheKey = "certificates"
    private let markSheetsCacheKey = "mark_sheets"

    init(apiClient: any APIClient, cache: ProfileCacheService) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func cachedCertificates() -> [Certificate]? {
        cache.load([Certificate].self, forKey: certificatesCacheKey)
    }

    func fetchCertificates() async throws -> [Certificate] {
        let dtos: [CertificateDTO] = try await apiClient.sendRequest(
            path: "/certificate",
            httpMethod: .GET
        )
        let certificates = dtos.map { $0.toDomain() }
        cache.save(certificates, forKey: certificatesCacheKey)
        return certificates
    }

    func cachedMarkSheets() -> [MarkSheet]? {
        cache.load([MarkSheet].self, forKey: markSheetsCacheKey)
    }

    func fetchMarkSheets() async throws -> [MarkSheet] {
        let dtos: [MarkSheetDTO] = try await apiClient.sendRequest(
            path: "/mark-sheet",
            httpMethod: .GET
        )
        let markSheets = dtos.map { $0.toDomain() }
        cache.save(markSheets, forKey: markSheetsCacheKey)
        return markSheets
    }
}

private extension CertificateDTO {
    func toDomain() -> Certificate {
        Certificate(
            id: id,
            number: number,
            type: certificateType,
            orderDate: dateOrder,
            issueDate: issueDate,
            deliveryPlace: provisionPlace,
            status: CertificateStatus(rawValue: status) ?? .unknown,
            rejectionReason: rejectionReason
        )
    }
}

private extension MarkSheetDTO {
    func toDomain() -> MarkSheet {
        MarkSheet(
            id: id,
            number: number,
            status: status,
            submitDate: createDate,
            absentDate: absentDate,
            expireDate: expireDate,
            hours: hours ?? 0,
            retakeCount: retakeCount,
            price: price ?? 0,
            isRespectful: reason,
            rejectionReason: rejectionReason,
            subjectName: subject.name,
            subjectAbbrev: subject.abbrev,
            lessonTypeAbbrev: subject.lessonTypeAbbrev,
            teacherFio: employee?.fio,
            typeName: markSheetType?.shortName
        )
    }
}
