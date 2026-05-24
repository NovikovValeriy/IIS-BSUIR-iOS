//
//  DirectoryRouter.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 24.05.26.
//

import SwiftUI
import Observation

@Observable
@MainActor
final class DirectoryRouter: @MainActor RouterProtocol {
    typealias Destination = DirectoryDestination

    var path: NavigationPath = .init()
    var alert: AppAlert?

    func navigateToRatings() { path.append(DirectoryDestination.ratings) }
    func navigateToSubjects() { path.append(DirectoryDestination.subjects) }
    func navigateToDepartments() { path.append(DirectoryDestination.departments) }
    func navigateToStudentGrades(_ cardNumber: String) { path.append(DirectoryDestination.studentGrades(cardNumber)) }

    func present(alert: AppAlert) { self.alert = alert }
}
