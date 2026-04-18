//
//  LoginViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation
import Factory

@Observable
@MainActor
final class LoginViewModel {
    var username: String = ""
    var password: String = ""
    var rememberDevice: Bool = true
    var isLoading: Bool = false

    private let authService: any AuthServiceProtocol
    private let appCoordinator: AppCoordinator
    private let router: AuthRouter

    init(
        authService: any AuthServiceProtocol,
        appCoordinator: AppCoordinator,
        router: AuthRouter
    ) {
        self.authService = authService
        self.appCoordinator = appCoordinator
        self.router = router
    }

    var canSubmit: Bool {
        !username.isEmpty && !password.isEmpty && !isLoading
    }

    func login() async {
        guard canSubmit else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await authService.login(
                username: username,
                password: password,
                rememberDevice: rememberDevice
            )
            appCoordinator.userDidAuthenticate(user: response)
        } catch let error as APIError {
            router.present(alert: .error(error.localizedDescription))
        } catch {
            router.present(alert: .error(error.localizedDescription))
        }
    }

    func didTapForgotPassword() {
        router.push(.forgotPassword)
    }
}
