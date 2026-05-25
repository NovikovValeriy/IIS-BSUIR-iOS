//
//  DepartmentsViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

import Foundation

@Observable
@MainActor
final class DepartmentsViewModel {
    private let service: any DepartmentServiceProtocol
    private let router: DirectoryRouter

    private(set) var departments: [Department] = []
    private(set) var isLoading = false

    init(service: any DepartmentServiceProtocol, router: DirectoryRouter) {
        self.service = service
        self.router = router
    }

    func load() async {
        guard !isLoading else { return }
        if let cached = service.cachedDepartments() {
            departments = cached
        }
        isLoading = true
        defer { isLoading = false }
        do {
            departments = try await service.fetchDepartments()
        } catch {
            print(error.localizedDescription)
        }
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            departments = try await service.fetchDepartments()
        } catch {
            print(error.localizedDescription)
        }
    }

    func didTapDepartment(_ department: Department) {
        router.navigateToDepartmentEmployees(department)
    }
}
