//
//  GroupInfoViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

import Foundation

@Observable
@MainActor
final class GroupInfoViewModel {
    private let service: any GroupInfoServiceProtocol
    private let storage: any StorageProtocol

    private(set) var groupInfo: GroupInfo?
    private(set) var isLoading = false
    private(set) var groupNumber: String?

    init(service: any GroupInfoServiceProtocol, storage: any StorageProtocol) {
        self.service = service
        self.storage = storage
        self.groupNumber = storage.value(for: .groupNumber)
    }

    func load() async {
        guard !isLoading else { return }
        groupInfo = service.cachedGroupInfo()
        if let cached = groupInfo { groupNumber = cached.groupNumber }
        isLoading = true
        defer { isLoading = false }
        do {
            groupInfo = try await service.fetchGroupInfo()
            groupNumber = groupInfo?.groupNumber
        } catch {
            print(error.localizedDescription)
        }
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            groupInfo = try await service.fetchGroupInfo()
            groupNumber = groupInfo?.groupNumber
        } catch {
            print(error.localizedDescription)
        }
    }
}
