//
//  Container+Profile.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Factory
import SwiftData

extension Container {
    var profileRouter: Factory<ProfileRouter> {
        self { @MainActor in ProfileRouter() }.shared
    }

    var profileViewModel: Factory<ProfileViewModel> {
        self { @MainActor in
            ProfileViewModel(
                router: self.profileRouter(),
                authState: self.authState(),
                appCoordinator: self.appCoordinator()
            )
        }
    }

    // swiftlint:disable force_try
    var profileModelContainer: Factory<ModelContainer> {
        self { @MainActor in
            let schema = Schema([CachedProfileEntry.self])
            let config = ModelConfiguration("profile", schema: schema, isStoredInMemoryOnly: false)
            if let container = try? ModelContainer(for: schema, configurations: [config]) {
                return container
            }
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [fallback])
        }.singleton
    }
    // swiftlint:enable force_try

    var profileCacheService: Factory<ProfileCacheService> {
        self { @MainActor in ProfileCacheService(modelContainer: self.profileModelContainer()) }.shared
    }

    var groupInfoService: Factory<any GroupInfoServiceProtocol> {
        self { @MainActor in
            GroupInfoService(apiClient: self.apiClient(), cache: self.profileCacheService(), storage: self.storage())
        }.shared
    }

    var groupInfoViewModel: Factory<GroupInfoViewModel> {
        self { @MainActor in GroupInfoViewModel(service: self.groupInfoService(), storage: self.storage()) }
    }
}
