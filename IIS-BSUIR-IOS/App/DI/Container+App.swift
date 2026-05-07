//
//  Container+App.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation
import Factory
import SwiftData

extension Container {
    var authState: Factory<AuthState> {
        self { @MainActor in AuthState() }.singleton
    }

    var authService: Factory<any AuthServiceProtocol> {
         self { @MainActor in AuthService(apiClient: self.apiClient(), keychain: self.keychain()) }.singleton
    }

    var storage: Factory<any StorageProtocol> {
        self { @MainActor in UserDefaultsStorage() }.shared
    }

    var appCoordinator: Factory<AppCoordinator> {
        self { @MainActor in AppCoordinator(authState: self.authState(), authService: self.authService()) }.singleton
    }

    var tabCoordinator: Factory<TabCoordinator> {
        self { @MainActor in TabCoordinator() }.shared
    }

    // MARK: - Real networking (unused while mocking)
    var keychain: Factory<KeychainService> {
        self { @MainActor in KeychainService() }.shared
    }

    var apiClient: Factory<any APIClient> {
        self { @MainActor in
            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
            return DefaultAPIClient(
                baseURL: URL(string: "https://iis.bsuir.by/api/v1")!,
                keychain: self.keychain(),
                session: session
            )
        }.shared
    }

    // swiftlint:disable force_try
    var scheduleModelContainer: Factory<ModelContainer> {
        self { @MainActor in
            let schema = Schema([CachedScheduleEntry.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            if let container = try? ModelContainer(for: schema, configurations: [config]) {
                return container
            }
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [fallback])
        }.singleton
    }
    // swiftlint:enable force_try
}
