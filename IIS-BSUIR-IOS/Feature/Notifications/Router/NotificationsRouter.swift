//
//  NotificationsRouter.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class NotificationsRouter: @MainActor RouterProtocol {
    typealias Destination = NotificationsDestination

    var path: NavigationPath = .init()
    var presentedSheet: NotificationsSheet?
    var alert: AppAlert?

    func present(sheet: NotificationsSheet) { presentedSheet = sheet }
    func dismissSheet() { presentedSheet = nil }
    func present(alert: AppAlert) { self.alert = alert }
}
