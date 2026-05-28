//
//  OmissionsViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 28.05.26.
//

import Foundation

@Observable
@MainActor
final class OmissionsViewModel {
    private let service: any OmissionsServiceProtocol

    private(set) var data: OmissionsData?
    private(set) var isLoading = false

    var applications: [OmissionApplication] { data?.applications ?? [] }

    var currentSemesterHours: Int? {
        guard let data else { return nil }
        return data.semesterCounts.max(by: { $0.term < $1.term })?.totalHours ?? 0
    }

    var semesterGroups: [(term: Int, documents: [OmissionDocument], totalHours: Int)] {
        guard let data else { return [] }
        let allTerms = Set(data.documents.map(\.term))
            .union(Set(data.semesterCounts.map(\.term)))
        let grouped = Dictionary(grouping: data.documents, by: \.term)
        return allTerms
            .map { term in
                let hours = data.semesterCounts.first(where: { $0.term == term })?.totalHours ?? 0
                return (term: term, documents: grouped[term] ?? [], totalHours: hours)
            }
            .sorted { $0.term < $1.term }
    }

    init(service: any OmissionsServiceProtocol) {
        self.service = service
        self.data = service.cachedOmissions()
    }

    func load() async {
        guard !isLoading else { return }
        if data == nil { isLoading = true }
        defer { isLoading = false }
        do {
            data = try await service.fetchOmissions()
        } catch {
            print(error.localizedDescription)
        }
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            data = try await service.fetchOmissions()
        } catch {
            print(error.localizedDescription)
        }
    }
}
