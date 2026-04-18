//
//  Container+App.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation
import Factory

extension Container {
    var authState: Factory<AuthState> {
        self { @MainActor in AuthState() }.shared
    }

    // MARK: - Swap these two lines when real networking is ready
    var authService: Factory<any AuthServiceProtocol> {
        self { @MainActor in MockAuthService() }.shared
        // self { @MainActor in AuthService(apiClient: self.apiClient(), keychain: self.keychain()) }.shared
    }

    var storage: Factory<any StorageProtocol> {
        self { @MainActor in UserDefaultsStorage() }.shared
    }

    var appCoordinator: Factory<AppCoordinator> {
        self { @MainActor in AppCoordinator(authState: self.authState(), authService: self.authService()) }.shared
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
            let delegate = BsuirTLSDelegate()
            let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
            return DefaultAPIClient(
                baseURL: URL(string: "https://iis.bsuir.by")!,
                keychain: self.keychain(),
                session: session
            )
        }.shared
    }
}
