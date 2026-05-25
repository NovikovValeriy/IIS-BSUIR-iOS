//
//  GroupInfoService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

import Foundation

@MainActor
protocol GroupInfoServiceProtocol: AnyObject {
    func cachedGroupInfo() -> GroupInfo?
    func fetchGroupInfo() async throws -> GroupInfo
}

@MainActor
final class GroupInfoService: GroupInfoServiceProtocol {
    private let apiClient: any APIClient
    private let cache: ProfileCacheService
    private let storage: any StorageProtocol
    private let cacheKey = "group_info"

    init(apiClient: any APIClient, cache: ProfileCacheService, storage: any StorageProtocol) {
        self.apiClient = apiClient
        self.cache = cache
        self.storage = storage
    }

    func cachedGroupInfo() -> GroupInfo? {
        cache.load(GroupInfo.self, forKey: cacheKey)
    }

    func fetchGroupInfo() async throws -> GroupInfo {
        let dto: GroupInfoResponseDTO = try await apiClient.sendRequest(
            path: "/student-groups/user-group-info",
            httpMethod: .GET
        )
        let info = dto.toGroupInfo()
        cache.save(info, forKey: cacheKey)
        storage.setValue(info.groupNumber, for: .groupNumber)
        return info
    }
}

private extension GroupInfoResponseDTO {
    func toGroupInfo() -> GroupInfo {
        GroupInfo(
            groupNumber: numberOfGroup,
            curator: GroupCurator(
                fio: studentGroupCuratorDto.fio,
                phone: studentGroupCuratorDto.phone,
                email: studentGroupCuratorDto.email
            ),
            students: groupInfoStudentDto.map { dto in
                GroupStudent(
                    fio: dto.fio,
                    position: dto.position.isEmpty ? nil : dto.position
                )
            }
        )
    }
}
