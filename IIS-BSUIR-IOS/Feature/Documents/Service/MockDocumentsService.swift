//
//  MockDocumentsService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

@MainActor
final class MockDocumentsService: DocumentsServiceProtocol {
    private var mockCertificates: [Certificate] = [
        Certificate(
            id: 1001,
            number: 321,
            type: "обычная",
            orderDate: "15.03.2026",
            issueDate: "16.03.2026",
            deliveryPlace: "по месту работы родителей",
            status: .printed,
            rejectionReason: nil
        )
    ]
    private var nextId = 1002
    private var nextNumber = 322

    func cachedCertificates() -> [Certificate]? { nil }

    func fetchCertificates() async throws -> [Certificate] {
        try await Task.sleep(for: .milliseconds(600))
        return mockCertificates
    }

    func cachedMarkSheets() -> [MarkSheet]? { nil }

    func fetchMarkSheets() async throws -> [MarkSheet] {
        try await Task.sleep(for: .milliseconds(600))
        return []
    }

    func fetchCertificatePlaces() async throws -> [CertificatePlaceCategory] {
        try await Task.sleep(for: .milliseconds(400))
        return [
            CertificatePlaceCategory(type: "обычная", places: [
                CertificatePlace(id: 1, name: "по месту работы родителей"),
                CertificatePlace(id: 2, name: "в военкомат"),
                CertificatePlace(id: 3, name: "в посольство"),
                CertificatePlace(id: 4, name: "по месту требования"),
                CertificatePlace(id: 5, name: "в налоговую инспекцию")
            ]),
            CertificatePlaceCategory(type: "СППС", places: [
                CertificatePlace(id: 6, name: "в ФСЗН"),
                CertificatePlace(id: 7, name: "в банк"),
                CertificatePlace(id: 8, name: "в соц. защиту")
            ])
        ]
    }

    func orderCertificate(type: String, place: String, count: Int) async throws {
        try await Task.sleep(for: .milliseconds(800))
        let today = Self.todayString()
        for _ in 0..<count {
            mockCertificates.insert(
                Certificate(
                    id: nextId,
                    number: nextNumber,
                    type: type,
                    orderDate: today,
                    issueDate: nil,
                    deliveryPlace: place,
                    status: .processing,
                    rejectionReason: nil
                ),
                at: 0
            )
            nextId += 1
            nextNumber += 1
        }
    }

    private static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: Date())
    }
}
