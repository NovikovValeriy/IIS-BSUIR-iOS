//
//  DepartmentService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

import Foundation

@MainActor
protocol DepartmentServiceProtocol: AnyObject {
    func cachedDepartments() -> [DepartmentNode]?
    func fetchDepartments() async throws -> [DepartmentNode]
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

    func cachedDepartments() -> [DepartmentNode]? {
        cache.load([DepartmentNode].self, forKey: "departments")
    }

    func fetchDepartments() async throws -> [DepartmentNode] {
        let dtos: [DepartmentTreeNodeDTO] = try await apiClient.sendRequest(
            path: "/departments/tree",
            httpMethod: .GET
        )
        let nodes = buildTree(dtos, prefix: "")
        cache.save(nodes, forKey: "departments")
        return nodes
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

    private func buildTree(_ dtos: [DepartmentTreeNodeDTO], prefix: String) -> [DepartmentNode] {
        dtos.enumerated().map { index, dto in
            let number = prefix.isEmpty ? "\(index + 1)" : "\(prefix).\(index + 1)"
            return DepartmentNode(
                number: number,
                department: Department(
                    id: dto.data.id,
                    name: dto.data.name,
                    abbrev: dto.data.abbrev,
                    urlId: dto.data.urlId
                ),
                employeeCount: dto.data.employees?.count ?? 0,
                children: buildTree(dto.children ?? [], prefix: number)
            )
        }
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
