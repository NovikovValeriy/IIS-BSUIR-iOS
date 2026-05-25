//
//  DepartmentsViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

import Foundation

struct FlatDepartmentItem: Identifiable {
    let node: DepartmentNode
    let depth: Int
    var id: Int { node.id }
}

@Observable
@MainActor
final class DepartmentsViewModel {
    private let service: any DepartmentServiceProtocol
    private let router: DirectoryRouter

    private(set) var nodes: [DepartmentNode] = []
    private(set) var isLoading = false
    private var expandedIds: Set<Int> = []

    var flatItems: [FlatDepartmentItem] {
        buildFlatItems(from: nodes, depth: 0)
    }

    init(service: any DepartmentServiceProtocol, router: DirectoryRouter) {
        self.service = service
        self.router = router
    }

    func load() async {
        guard !isLoading else { return }
        if let cached = service.cachedDepartments() {
            nodes = cached
        }
        isLoading = true
        defer { isLoading = false }
        do {
            nodes = try await service.fetchDepartments()
        } catch {
            print(error.localizedDescription)
        }
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            nodes = try await service.fetchDepartments()
        } catch {
            print(error.localizedDescription)
        }
    }

    func isExpanded(_ node: DepartmentNode) -> Bool {
        expandedIds.contains(node.id)
    }

    func toggleExpanded(_ node: DepartmentNode) {
        if expandedIds.contains(node.id) {
            expandedIds.remove(node.id)
        } else {
            expandedIds.insert(node.id)
        }
    }

    func didTapDepartment(_ node: DepartmentNode) {
        guard node.hasEmployees else { return }
        router.navigateToDepartmentEmployees(node.department)
    }

    private func buildFlatItems(from nodes: [DepartmentNode], depth: Int) -> [FlatDepartmentItem] {
        nodes.flatMap { node -> [FlatDepartmentItem] in
            let item = FlatDepartmentItem(node: node, depth: depth)
            guard expandedIds.contains(node.id) else { return [item] }
            return [item] + buildFlatItems(from: node.children, depth: depth + 1)
        }
    }
}
