//
//  Container+Announcements.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Factory

extension Container {
    var announcementsService: Factory<any AnnouncementsServiceProtocol> {
        self { @MainActor in
            AnnouncementsService(apiClient: self.apiClient(), cache: self.profileCacheService())
        }.shared
    }

    var announcementsViewModel: Factory<AnnouncementsViewModel> {
        self { @MainActor in AnnouncementsViewModel(service: self.announcementsService()) }
    }
}
