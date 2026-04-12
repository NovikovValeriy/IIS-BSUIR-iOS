//
//  SettingsRouter.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class SettingsRouter: @MainActor RouterProtocol {
    typealias Destination = SettingsDestination

    var path: NavigationPath = .init()
    var alert: AppAlert?

    func present(alert: AppAlert) { self.alert = alert }
}
