//
//  Container+AuthFeature.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation
import Factory

extension Container {
    var authRouter: Factory<AuthRouter> {
        self { @MainActor in AuthRouter() }.shared
    }

    var loginViewModel: Factory<LoginViewModel> {
        self { @MainActor in
            LoginViewModel(
                authService: self.authService(),
                appCoordinator: self.appCoordinator(),
                router: self.authRouter()
            )
        }
    }
}
