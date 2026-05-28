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

    func navigateToMarkBook() { path.append(ProfileDestination.markBook) }
    func navigateToGrades() { path.append(ProfileDestination.grades) }
    func navigateToCertificates() { path.append(ProfileDestination.certificates) }
    func navigateToGroupInfo() { path.append(ProfileDestination.groupInfo) }
    func navigateToAnnouncements() { path.append(ProfileDestination.announcements) }
    func navigateToDormitory() { path.append(ProfileDestination.dormitory) }
    func navigateToPenalties() { path.append(ProfileDestination.penalties) }
    func navigateToActivity() { path.append(ProfileDestination.activity) }
    func navigateToLibrary() { path.append(ProfileDestination.library) }
    func navigateToOmissions() { path.append(ProfileDestination.omissions) }
    func present(confirmationDialog: ProfileConfirmationDialog) { self.confirmationDialog = confirmationDialog }
    func present(alert: AppAlert) { self.alert = alert }
}
