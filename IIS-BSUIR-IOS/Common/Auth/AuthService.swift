//
//  AuthService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

@MainActor
protocol AuthServiceProtocol: AnyObject {
    func login(username: String, password: String, rememberDevice: Bool) async throws -> LoginResponseDTO
    func logout() async
    func validateStoredSession() async -> LoginResponseDTO?
}

@MainActor
final class AuthService: AuthServiceProtocol {
    private let apiClient: any APIClient
    private let keychain: KeychainService

    init(apiClient: any APIClient, keychain: KeychainService) {
        self.apiClient = apiClient
        self.keychain = keychain
    }

    func login(username: String, password: String, rememberDevice: Bool) async throws -> LoginResponseDTO {
        let body = LoginRequestDTO(username: username, password: password, rememberDevice: rememberDevice)
        let response: LoginResponseDTO = try await apiClient.sendRequest(
            path: "/api/v1/auth/login",
            httpMethod: .POST,
            body: .jsonBody(body)
        )
        keychain.save(username, forKey: KeychainService.Keys.username)
        return response
    }

    func logout() async {
        keychain.clearAll()
    }

    func validateStoredSession() async -> LoginResponseDTO? {
        guard keychain.load(forKey: KeychainService.Keys.username) != nil else {
            return nil
        }
        do {
            let profile: LoginResponseDTO = try await apiClient.sendRequest(
                path: "/api/v1/profile/me",
                httpMethod: .GET
            )
            return profile
        } catch {
            keychain.clearAll()
            return nil
        }
    }
}
