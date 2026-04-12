//
//  ScheduleRouter.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class ScheduleRouter: @MainActor RouterProtocol {
    typealias Destination = ScheduleDestination

    var path: NavigationPath = .init()
    var presentedSheet: ScheduleSheet?
    var alert: AppAlert?

    func present(sheet: ScheduleSheet) { presentedSheet = sheet }
    func dismissSheet() { presentedSheet = nil }
    func present(alert: AppAlert) { self.alert = alert }
}
