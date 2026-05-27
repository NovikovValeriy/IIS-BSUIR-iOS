//
//  Container+Dormitory.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Factory

extension Container {
    var dormitoryService: Factory<any DormitoryServiceProtocol> {
        self { @MainActor in
            DormitoryService(apiClient: self.apiClient(), cache: self.profileCacheService())
        }.shared
    }

    var dormitoryViewModel: Factory<DormitoryViewModel> {
        self { @MainActor in DormitoryViewModel(service: self.dormitoryService()) }
    }
}
