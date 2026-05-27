//
//  DepartmentEmployeesViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

import Foundation

@Observable
@MainActor
final class DepartmentEmployeesViewModel {
    private let service: any DepartmentServiceProtocol
    let department: Department

    private(set) var employees: [DepartmentEmployee] = []
    private(set) var isLoading = false

    init(service: any DepartmentServiceProtocol, department: Department) {
        self.service = service
        self.department = department
    }

    func load() async {
        guard !isLoading else { return }
        if let cached = service.cachedEmployees(urlId: department.urlId) {
            employees = cached
        }
        if employees.isEmpty { isLoading = true }
        defer { isLoading = false }
        do {
            employees = try await service.fetchEmployees(urlId: department.urlId)
        } catch {
            print(error.localizedDescription)
        }
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            employees = try await service.fetchEmployees(urlId: department.urlId)
        } catch {
            print(error.localizedDescription)
        }
    }
}
