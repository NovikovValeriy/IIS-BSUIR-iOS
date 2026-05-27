//
//  Container+Documents.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Factory

extension Container {
    var documentsService: Factory<any DocumentsServiceProtocol> {
        self { @MainActor in
            DocumentsService(apiClient: self.apiClient(), cache: self.profileCacheService())
        }.shared
    }

    var documentsViewModel: Factory<DocumentsViewModel> {
        self { @MainActor in DocumentsViewModel(service: self.documentsService()) }
    }
}
