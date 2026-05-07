//
//  DefaultAPIClient.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import Foundation

final class DefaultAPIClient: APIClient {
    let baseURL: URL
    private let session: URLSession
    private let keychain: KeychainService

    init(
        baseURL: URL,
        keychain: KeychainService,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.keychain = keychain
        self.session = session
    }

    func send(request: URLRequest) async throws(APIError) -> APIResponse {
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            let headers = httpResponse.allHeaderFields.reduce(into: [String: String]()) { result, pair in
                if let key = pair.key as? String, let value = pair.value as? String {
                    result[key] = value
                }
            }
            return APIResponse(statusCode: httpResponse.statusCode, data: data, headers: headers)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.unknown
        }
    }

    func defaultHeaders(additionalHeaders: [String: String]) throws(APIError) -> [String: String] {
        var headers: [String: String] = [
            "Accept": "application/json"
        ]
        if let token = keychain.load(forKey: KeychainService.Keys.authToken) {
            headers["Cookie"] = "SESSION=\(token)"
        }
        additionalHeaders.forEach { headers[$0.key] = $0.value }
        return headers
    }
}
