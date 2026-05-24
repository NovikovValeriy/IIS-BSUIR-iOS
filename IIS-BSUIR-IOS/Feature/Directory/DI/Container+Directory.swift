//
//  Container+Directory.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 24.05.26.
//

import Factory

extension Container {
    var directoryRouter: Factory<DirectoryRouter> {
        self { @MainActor in DirectoryRouter() }.shared
    }
}
