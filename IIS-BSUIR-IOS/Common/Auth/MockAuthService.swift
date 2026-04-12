//
//  MockAuthService.swift
//  IIS-BSUIR-IOS
//

import Foundation

@MainActor
final class MockAuthService: AuthServiceProtocol {
    static let fakeUser = LoginResponseDTO(
        authorities: ["ROLE_STUDENT"],
        canStudentNote: true,
        email: "student@bsuir.by",
        fio: "Novikau Valery Alexandrovich",
        group: "253502",
        hasNotConfirmedContact: false,
        isGroupHead: true,
        phone: "+375291234567",
        photoUrl: nil,
        username: "student"
    )

    // Set to true to start already logged in (skips login screen)
    var startAuthenticated = false

    func login(username: String, password: String, rememberDevice: Bool) async throws -> LoginResponseDTO {
        // Simulate a short network delay
        try await Task.sleep(for: .seconds(0.5))
        return Self.fakeUser
    }

    func logout() async {}

    func validateStoredSession() async -> LoginResponseDTO? {
        startAuthenticated ? Self.fakeUser : nil
    }
}
