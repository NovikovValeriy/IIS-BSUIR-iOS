//
//  GradesRouter.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class GradesRouter: @MainActor RouterProtocol {
    typealias Destination = GradesDestination

    var path: NavigationPath = .init()
    var presentedSheet: GradesSheet?
    var alert: AppAlert?

    func present(sheet: GradesSheet) { presentedSheet = sheet }
    func dismissSheet() { presentedSheet = nil }
    func present(alert: AppAlert) { self.alert = alert }
}
