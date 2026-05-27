//
//  AppCoordinator.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation
import Factory

@Observable
@MainActor
final class AppCoordinator {
    private let authState: AuthState
    private let authService: any AuthServiceProtocol
    private let storage: any StorageProtocol

    var isShowingAuth: Bool = false

    init(authState: AuthState, authService: any AuthServiceProtocol, storage: any StorageProtocol) {
        self.authState = authState
        self.authService = authService
        self.storage = storage
    }

    // Silently restore session on launch — does not block the UI
    func validateSession() async {
        if let user = await authService.validateStoredSession() {
            authState.transition(to: .authenticated(user: user))
        }
    }

    func presentAuth() {
        isShowingAuth = true
    }

    func userDidAuthenticate(user: User) {
        authState.transition(to: .authenticated(user: user))
        isShowingAuth = false
    }

    func userDidLogout() {
        Task {
            await authService.logout()
            storage.removeValue(for: .groupNumber)
            Container.shared.manager.reset(scope: .shared)
            authState.transition(to: .unauthenticated)
        }
    }

    func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        let tabCoordinator = Container.shared.tabCoordinator()
        switch components.host {
        case "schedule":
            tabCoordinator.select(.schedule)
        case "profile":
            tabCoordinator.select(.profile)
        case "settings":
            tabCoordinator.select(.settings)
        case "lesson":
            handleLessonDeepLink(queryItems: components.queryItems ?? [], tabCoordinator: tabCoordinator)
        default:
            break
        }
    }

    private func handleLessonDeepLink(queryItems: [URLQueryItem], tabCoordinator: TabCoordinator) {
        func value(for name: String) -> String? {
            queryItems.first(where: { $0.name == name })?.value
        }
        guard let subject = value(for: "subject"),
              let startTime = value(for: "startTime"),
              let weekday = value(for: "weekday")
        else { return }
        tabCoordinator.selectedTab = .pinnedSchedule
        NotificationCenter.default.post(
            name: .navigateToLesson,
            object: nil,
            userInfo: ["subject": subject, "startTime": startTime, "weekday": weekday]
        )
    }
}
