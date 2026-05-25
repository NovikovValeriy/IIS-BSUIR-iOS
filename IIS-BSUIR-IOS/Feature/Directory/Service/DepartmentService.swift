//
//  DepartmentService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

import Foundation

@MainActor
protocol DepartmentServiceProtocol: AnyObject {
    func cachedDepartments() -> [Department]?
    func fetchDepartments() async throws -> [Department]
    func cachedEmployees(urlId: String) -> [DepartmentEmployee]?
    func fetchEmployees(urlId: String) async throws -> [DepartmentEmployee]
}

@MainActor
final class DepartmentService: DepartmentServiceProtocol {
    private let apiClient: any APIClient
    private let cache: DepartmentCacheService

    init(apiClient: any APIClient, cache: DepartmentCacheService) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func cachedDepartments() -> [Department]? {
        cache.load([Department].self, forKey: "departments")
    }

    func fetchDepartments() async throws -> [Department] {
        let nodes: [DepartmentTreeNodeDTO] = try await apiClient.sendRequest(
            path: "/departments/tree",
            httpMethod: .GET
        )
        let departments = nodes.flatMap { flatten($0) }
        cache.save(departments, forKey: "departments")
        return departments
    }

    func cachedEmployees(urlId: String) -> [DepartmentEmployee]? {
        cache.load([DepartmentEmployee].self, forKey: "employees:\(urlId)")
    }

    func fetchEmployees(urlId: String) async throws -> [DepartmentEmployee] {
        let dtos: [DepartmentEmployeeDetailDTO] = try await apiClient.sendRequest(
            path: "/employees",
            httpMethod: .GET,
            queryParams: ["departmentUrlId": urlId]
        )
        let employees = dtos.map { $0.toDepartmentEmployee() }
        cache.save(employees, forKey: "employees:\(urlId)")
        return employees
    }

    private func flatten(_ node: DepartmentTreeNodeDTO) -> [Department] {
        let dept = Department(
            id: node.data.id,
            name: node.data.name,
            abbrev: node.data.abbrev,
            urlId: node.data.urlId
        )
        let childDepts = node.children?.flatMap { flatten($0) } ?? []
        return [dept] + childDepts
    }
}

private extension DepartmentEmployeeDetailDTO {
    func toDepartmentEmployee() -> DepartmentEmployee {
        let fio = [lastName, firstName, middleName]
            .compactMap { $0 }
            .joined(separator: " ")
        let position = jobPositions?.first?.jobPosition
        let phones = jobPositions?
            .compactMap { $0.contacts }
            .flatMap { $0 }
            .compactMap { $0.phoneNumber }
            ?? []
        return DepartmentEmployee(
            id: id,
            fio: fio,
            photoLink: photoLink,
            jobPosition: position.flatMap { $0.isEmpty ? nil : $0 },
            phones: phones
        )
    }
}
