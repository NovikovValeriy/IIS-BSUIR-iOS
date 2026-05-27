//
//  DormitoryViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

@Observable
@MainActor
final class DormitoryViewModel {
    private let service: any DormitoryServiceProtocol

    private(set) var data: DormitoryData?
    private(set) var isLoading = false

    init(service: any DormitoryServiceProtocol) {
        self.service = service
        self.data = service.cachedDormitoryData()
    }

    func load() async {
        guard !isLoading else { return }
        if data == nil {
            isLoading = true
        }
        defer { isLoading = false }
        do {
            data = try await service.fetchDormitoryData()
        } catch {
            print(error.localizedDescription)
        }
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            data = try await service.fetchDormitoryData()
        } catch {
            print(error.localizedDescription)
        }
    }
}
