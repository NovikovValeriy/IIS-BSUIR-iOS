//
//  LibraryService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 28.05.26.
//

import Foundation

@MainActor
protocol LibraryServiceProtocol: AnyObject {
    func fetchBooks() async throws
}

@MainActor
final class LibraryService: LibraryServiceProtocol {
    private let apiClient: any APIClient

    init(apiClient: any APIClient) {
        self.apiClient = apiClient
    }

    func fetchBooks() async throws {
        try await apiClient.sendRequest(path: "/library/books", httpMethod: .GET)
    }
}
