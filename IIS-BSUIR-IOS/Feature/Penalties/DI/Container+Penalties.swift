//
//  Container+Penalties.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Factory

extension Container {
    var penaltiesService: Factory<any PenaltiesServiceProtocol> {
//        self { @MainActor in
//            PenaltiesService(apiClient: self.apiClient(), cache: self.profileCacheService())
//        }.shared
        self { @MainActor in MockPenaltiesService() }.shared
    }

    var penaltiesViewModel: Factory<PenaltiesViewModel> {
        self { @MainActor in PenaltiesViewModel(service: self.penaltiesService()) }
    }
}
