//
//  AuthRouter.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class AuthRouter: @MainActor RouterProtocol {
    typealias Destination = AuthDestination

    var path: NavigationPath = .init()
    var presentedSheet: AuthSheet?
    var alert: AppAlert?

    func present(sheet: AuthSheet) {
        presentedSheet = sheet
    }

    func dismissSheet() {
        presentedSheet = nil
    }

    func present(alert: AppAlert) {
        self.alert = alert
    }
}
