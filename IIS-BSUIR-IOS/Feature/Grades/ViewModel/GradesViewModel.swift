//
//  GradesViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

@Observable
@MainActor
final class GradesViewModel {
    private let router: GradesRouter

    init(router: GradesRouter) {
        self.router = router
    }

    func didTapSubject(name: String) {
        router.push(.gradeBookDetail(subjectName: name))
    }

    func didTapOmissions() {
        router.push(.omissions)
    }
}
