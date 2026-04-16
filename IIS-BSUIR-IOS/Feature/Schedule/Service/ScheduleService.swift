//
//  ScheduleService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 13.04.26.
//

import Foundation

protocol ScheduleServiceProtocol: AnyObject {
    func fetchGroups() async throws -> [StudentGroupDTO]
    func fetchGroupSchedule(groupName: String) async throws -> ScheduleResponseDTO
    func fetchCurrentWeek() async throws -> Int
}

final class ScheduleService: ScheduleServiceProtocol {
    private let apiClient: any APIClient

    init(apiClient: any APIClient) {
        self.apiClient = apiClient
    }

    func fetchGroups() async throws -> [StudentGroupDTO] {
        try await apiClient.sendRequest(
            path: "/api/v1/student-groups",
            httpMethod: .GET
        )
    }

    func fetchGroupSchedule(groupName: String) async throws -> ScheduleResponseDTO {
        try await apiClient.sendRequest(
            path: "/api/v1/schedule",
            httpMethod: .GET,
            queryParams: ["studentGroup": groupName]
        )
    }

    func fetchCurrentWeek() async throws -> Int {
        try await apiClient.sendRequest(
            path: "/api/v1/schedule/current-week",
            httpMethod: .GET
        )
    }
}
