//
//  Container+Grades.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Factory

extension Container {
    var gradesRouter: Factory<GradesRouter> {
        self { @MainActor in GradesRouter() }.shared
    }

    var gradesViewModel: Factory<GradesViewModel> {
        self { @MainActor in GradesViewModel(router: self.gradesRouter()) }
    }
}
