//
//  ActivityViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

@Observable
@MainActor
final class ActivityViewModel {
    private let service: any ActivityServiceProtocol

    private(set) var activityData: ActivityData?
    private(set) var isLoading = false

    init(service: any ActivityServiceProtocol) {
        self.service = service
        self.activityData = service.cachedActivityData()
    }

    func load() async {
        guard !isLoading else { return }
        if activityData == nil {
            isLoading = true
        }
        defer { isLoading = false }
        do {
            activityData = try await service.fetchActivityData()
        } catch {
            print(error.localizedDescription)
        }
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            activityData = try await service.fetchActivityData()
        } catch {
            print(error.localizedDescription)
        }
    }
}
