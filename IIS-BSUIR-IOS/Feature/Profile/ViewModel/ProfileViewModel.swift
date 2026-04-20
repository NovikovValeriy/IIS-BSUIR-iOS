//
//  ProfileViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation
import Factory

@Observable
@MainActor
final class ProfileViewModel {
    private let router: ProfileRouter
    private let authState: AuthState
    private let appCoordinator: AppCoordinator

    init(router: ProfileRouter, authState: AuthState, appCoordinator: AppCoordinator) {
        self.router = router
        self.authState = authState
        self.appCoordinator = appCoordinator
    }

    var isAuthenticated: Bool {
        if case .authenticated = authState.status { return true }
        return false
    }

    var authenticatedUser: User? {
        if case .authenticated(let user) = authState.status { return user }
        return nil
    }

    func didTapSignIn() {
        appCoordinator.presentAuth()
    }

    func didTapLogout() {
        router.present(confirmationDialog: .logout)
    }

    func confirmLogout() {
        appCoordinator.userDidLogout()
    }
}
