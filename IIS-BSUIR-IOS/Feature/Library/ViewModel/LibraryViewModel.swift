//
//  LibraryViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 28.05.26.
//

import Foundation

@Observable
@MainActor
final class LibraryViewModel {
    private let service: any LibraryServiceProtocol

    private(set) var isLoading = false
    private(set) var hasLoaded = false

    init(service: any LibraryServiceProtocol) {
        self.service = service
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await service.fetchBooks()
        } catch {
            print(error.localizedDescription)
        }
        hasLoaded = true
    }
}
