//
//  MockAuthService.swift
//  IIS-BSUIR-IOS
//

import Foundation

@MainActor
final class MockAuthService: AuthServiceProtocol {
    static let fakeUser = User(
        username: "student",
        fio: "Novikau Valery Alexandrovich",
        group: "253502",
        email: "student@bsuir.by",
        phone: "+375291234567",
        photoUrl: nil,
        isGroupHead: true,
        canStudentNote: true,
        hasNotConfirmedContact: false,
        authorities: ["ROLE_STUDENT"]
    )

    // Set to true to start already logged in (skips login screen)
    var startAuthenticated = false

    func login(username: String, password: String, rememberDevice: Bool) async throws -> User {
        // Simulate a short network delay
        try await Task.sleep(for: .seconds(0.5))
        return Self.fakeUser
    }

    func logout() async {}

    func validateStoredSession() async -> User? {
        startAuthenticated ? Self.fakeUser : nil
    }
}
