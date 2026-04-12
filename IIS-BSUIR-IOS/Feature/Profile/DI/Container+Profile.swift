//
//  Container+Profile.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Factory

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
}
