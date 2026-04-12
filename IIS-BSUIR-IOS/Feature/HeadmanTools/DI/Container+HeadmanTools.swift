//
//  Container+HeadmanTools.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Factory

extension Container {
    var headmanToolsRouter: Factory<HeadmanToolsRouter> {
        self { @MainActor in HeadmanToolsRouter() }.shared
    }

    var headmanToolsViewModel: Factory<HeadmanToolsViewModel> {
        self { @MainActor in HeadmanToolsViewModel(router: self.headmanToolsRouter()) }
    }
}
