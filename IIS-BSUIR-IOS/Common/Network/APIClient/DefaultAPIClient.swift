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

    private enum Retry {
        static let maxAttempts = 3
        static let baseDelay: TimeInterval = 1.0
    }

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
        var lastError: APIError = .unknown
        for attempt in 0..<Retry.maxAttempts {
            if Task.isCancelled { break }
            if attempt > 0 {
                let delay = Retry.baseDelay * pow(2.0, Double(attempt - 1))
                try? await Task.sleep(for: .seconds(delay))
            }
            do {
                let (data, response) = try await session.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    lastError = .invalidResponse
                    continue
                }
                if (500...599).contains(httpResponse.statusCode) {
                    lastError = .networkError(statusCode: httpResponse.statusCode)
                    continue
                }
                let headers = httpResponse.allHeaderFields.reduce(into: [String: String]()) { result, pair in
                    if let key = pair.key as? String, let value = pair.value as? String {
                        result[key] = value
                    }
                }
                return APIResponse(statusCode: httpResponse.statusCode, data: data, headers: headers)
            } catch {
                lastError = .unknown
            }
        }
        throw lastError
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
