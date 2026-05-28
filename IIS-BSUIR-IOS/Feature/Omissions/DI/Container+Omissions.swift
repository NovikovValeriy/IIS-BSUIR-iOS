//
//  Container+Omissions.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 28.05.26.
//

import Factory

extension Container {
    var omissionsService: Factory<any OmissionsServiceProtocol> {
        self { @MainActor in
            OmissionsService(apiClient: self.apiClient(), cache: self.profileCacheService())
        }.shared
    }

    var omissionsViewModel: Factory<OmissionsViewModel> {
        self { @MainActor in OmissionsViewModel(service: self.omissionsService()) }
    }
}
