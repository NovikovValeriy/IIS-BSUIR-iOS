//
//  PenaltiesViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

@Observable
@MainActor
final class PenaltiesViewModel {
    private let service: any PenaltiesServiceProtocol

    private(set) var records: [PenaltyIncentiveRecord]?
    private(set) var isLoading = false

    var penalties: [PenaltyIncentiveRecord] { records?.filter { $0.isPenalty } ?? [] }
    var incentives: [PenaltyIncentiveRecord] { records?.filter { !$0.isPenalty } ?? [] }

    init(service: any PenaltiesServiceProtocol) {
        self.service = service
        self.records = service.cachedRecords()
    }

    func load() async {
        guard !isLoading else { return }
        if records == nil {
            isLoading = true
        }
        defer { isLoading = false }
        do {
            records = try await service.fetchRecords()
        } catch {
            print(error.localizedDescription)
        }
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            records = try await service.fetchRecords()
        } catch {
            print(error.localizedDescription)
        }
    }
}
