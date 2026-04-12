//
//  HeadmanToolsViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

@Observable
@MainActor
final class HeadmanToolsViewModel {
    private let router: HeadmanToolsRouter

    init(router: HeadmanToolsRouter) {
        self.router = router
    }

    func didTapOmissionsByDate(_ date: Date) {
        router.push(.omissionsByDate(date: date))
    }

    func didTapMarkSheet(id: String) {
        router.push(.markSheet(id: id))
    }
}
