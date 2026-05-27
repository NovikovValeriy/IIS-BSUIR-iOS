//
//  Container+Documents.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Factory

extension Container {
    var documentsService: Factory<any DocumentsServiceProtocol> {
//        self { @MainActor in
//            DocumentsService(apiClient: self.apiClient(), cache: self.profileCacheService())
//        }.shared
        self { @MainActor in MockDocumentsService() }.shared
    }

    var documentsViewModel: Factory<DocumentsViewModel> {
        self { @MainActor in DocumentsViewModel(service: self.documentsService()) }
    }

    var orderCertificateViewModel: Factory<OrderCertificateViewModel> {
        self { @MainActor in OrderCertificateViewModel(service: self.documentsService()) }
    }
}
