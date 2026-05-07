//
//  ProfileRouter.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class ProfileRouter: @MainActor RouterProtocol {
    typealias Destination = ProfileDestination

    var path: NavigationPath = .init()
    var confirmationDialog: ProfileConfirmationDialog?
    var alert: AppAlert?

    func navigateToGradeBook() { path.append(ProfileDestination.gradeBook) }
    func present(confirmationDialog: ProfileConfirmationDialog) { self.confirmationDialog = confirmationDialog }
    func present(alert: AppAlert) { self.alert = alert }
}
