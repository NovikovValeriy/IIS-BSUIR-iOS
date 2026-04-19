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
        let (response, apiResponse): (LoginResponseDTO, APIResponse) = try await apiClient.sendRequestWithAPIResponse(
            path: "/auth/login",
            httpMethod: .POST,
            body: .jsonBody(body)
        )
        keychain.save(username, forKey: KeychainService.Keys.username)
        if let jsessionId = apiResponse.jsessionId {
            keychain.save(jsessionId, forKey: KeychainService.Keys.authToken)
        }
        return response.toDomain()
    }

    func logout() async {
        keychain.clearAll()
    }

    func validateStoredSession() async -> User? {
        guard keychain.load(forKey: KeychainService.Keys.username) != nil else {
            return nil
        }
        do {
            let profile: LoginResponseDTO = try await apiClient.sendRequest(
                path: "/profile/me",
                httpMethod: .GET
            )
            return profile.toDomain()
        } catch {
            keychain.clearAll()
            return nil
        }
    }
}

// MARK: - Mapping

private extension LoginResponseDTO {
    func toDomain() -> User {
        User(
            username: username,
            fio: fio,
            group: group,
            email: email,
            phone: phone,
            photoUrl: photoUrl,
            isGroupHead: isGroupHead,
            canStudentNote: canStudentNote,
            hasNotConfirmedContact: hasNotConfirmedContact,
            authorities: authorities
        )
    }
}
