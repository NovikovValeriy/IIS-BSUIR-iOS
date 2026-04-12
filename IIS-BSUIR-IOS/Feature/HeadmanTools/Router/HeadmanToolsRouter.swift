//
//  HeadmanToolsRouter.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class HeadmanToolsRouter: @MainActor RouterProtocol {
    typealias Destination = HeadmanToolsDestination

    var path: NavigationPath = .init()
    var presentedSheet: HeadmanToolsSheet?
    var alert: AppAlert?

    func present(sheet: HeadmanToolsSheet) { presentedSheet = sheet }
    func dismissSheet() { presentedSheet = nil }
    func present(alert: AppAlert) { self.alert = alert }
}
