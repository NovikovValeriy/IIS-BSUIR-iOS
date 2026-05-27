//
//  Container+Activity.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Factory

extension Container {
    var activityService: Factory<any ActivityServiceProtocol> {
        self { @MainActor in
            ActivityService(apiClient: self.apiClient(), cache: self.profileCacheService())
        }.shared
    }

    var activityViewModel: Factory<ActivityViewModel> {
        self { @MainActor in ActivityViewModel(service: self.activityService()) }
    }
}
