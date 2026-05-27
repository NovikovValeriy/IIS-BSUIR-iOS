//
//  MockPenaltiesService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

@MainActor
final class MockPenaltiesService: PenaltiesServiceProtocol {
    func cachedRecords() -> [PenaltyIncentiveRecord]? { nil }

    func fetchRecords() async throws -> [PenaltyIncentiveRecord] {
        try await Task.sleep(for: .milliseconds(600))
        return Self.mockRecords
    }

    private static let mockRecords: [PenaltyIncentiveRecord] = [
        PenaltyIncentiveRecord(
            id: 1,
            isPenalty: true,
            eventTypeName: "Выговор",
            directiveNumber: "123-дисц",
            date: "14.11.2025",
            status: "действует",
            note: "Нарушение учебной дисциплины",
            reason: "Систематические пропуски занятий без уважительной причины"
        ),
        PenaltyIncentiveRecord(
            id: 2,
            isPenalty: true,
            eventTypeName: "Замечание",
            directiveNumber: "87-дисц",
            date: "03.09.2025",
            status: "снято",
            note: nil,
            reason: "Опоздание на занятие"
        ),
        PenaltyIncentiveRecord(
            id: 3,
            isPenalty: false,
            eventTypeName: "Благодарность",
            directiveNumber: "45-пр",
            date: "28.04.2025",
            status: "исполнено",
            note: "За активное участие в научной конференции",
            reason: nil
        ),
        PenaltyIncentiveRecord(
            id: 4,
            isPenalty: false,
            eventTypeName: "Грамота",
            directiveNumber: "12-пр",
            date: "15.01.2025",
            status: "исполнено",
            note: "Победитель внутриуниверситетской олимпиады по программированию",
            reason: nil
        )
    ]
}
