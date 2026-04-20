//
//  AuthService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

@MainActor
protocol AuthServiceProtocol: AnyObject {
    func login(username: String, password: String, rememberDevice: Bool) async throws -> User
    func logout() async
    func validateStoredSession() async -> User?
}

@MainActor
final class AuthService: AuthServiceProtocol {
    private let apiClient: any APIClient
    private let keychain: KeychainService

    init(apiClient: any APIClient, keychain: KeychainService) {
        self.apiClient = apiClient
        self.keychain = keychain
    }

    func login(username: String, password: String, rememberDevice: Bool) async throws -> User {
        let body = LoginRequestDTO(username: username, password: password, rememberDevice: rememberDevice)
        let (_, apiResponse): (LoginResponseDTO, APIResponse) = try await apiClient.sendRequestWithAPIResponse(
            path: "/auth/login",
            httpMethod: .POST,
            body: .jsonBody(body)
        )
        keychain.save(username, forKey: KeychainService.Keys.username)
        if let jsessionId = apiResponse.jsessionId {
            keychain.save(jsessionId, forKey: KeychainService.Keys.authToken)
        }
        return try await self.getPersonalProfile(username: username)
    }

    func logout() async {
        try? await apiClient.sendRequest(
            path: "/auth/logout",
            httpMethod: .GET
        )
        keychain.clearAll()
    }

    func validateStoredSession() async -> User? {
        guard let username = keychain.load(forKey: KeychainService.Keys.username) else {
            return nil
        }
        do {
            return try await self.getPersonalProfile(username: username)
        } catch {
            keychain.clearAll()
            return nil
        }
    }

    private func getPersonalProfile(username: String) async throws -> User {
        let profile: AccountProfileDTO = try await apiClient.sendRequest(
            path: "/profiles/personal-profile",
            httpMethod: .GET
        )
        return profile.toDomain(username: username)
    }
}

// MARK: - Mapping

private extension AccountProfileDTO {
    func toDomain(username: String) -> User {
        let nameParts = [lastName, firstName, middleName].compactMap { $0 }
        return User(
            username: username,
            fio: nameParts.joined(separator: " "),
            group: studentGroup ?? "",
            faculty: faculty,
            speciality: speciality,
            course: course,
            rating: rating,
            birthDate: birthDate,
            email: officeEmail,
            phone: "",
            photoUrl: photoUrl,
            isGroupHead: false,
            canStudentNote: false,
            hasNotConfirmedContact: false,
            authorities: []
        )
    }
}
