//
//  Container+Library.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 28.05.26.
//

import Factory

extension Container {
    var libraryService: Factory<any LibraryServiceProtocol> {
        self { @MainActor in LibraryService(apiClient: self.apiClient()) }.shared
    }

    var libraryViewModel: Factory<LibraryViewModel> {
        self { @MainActor in LibraryViewModel(service: self.libraryService()) }
    }
}
