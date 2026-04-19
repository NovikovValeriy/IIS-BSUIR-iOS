//
//  APIClient.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

import Foundation

protocol APIClient {
    var baseURL: URL { get }
    func send(request: URLRequest) async throws(APIError) -> APIResponse
    func defaultHeaders(additionalHeaders: [String: String]) throws(APIError) -> [String: String]
}

extension APIClient {
    func sendRequest<T: Decodable>(
        path: String,
        httpMethod: HTTPMethod,
        queryParams: [String: String]? = nil,
        body: APIRequestBody? = nil,
        additionalHeaders: [String: String] = [:]
    ) async throws(APIError) -> T {
        let (value, _): (T, APIResponse) = try await sendRequestWithAPIResponse(
            path: path,
            httpMethod: httpMethod,
            queryParams: queryParams,
            body: body,
            additionalHeaders: additionalHeaders
        )
        return value
    }

    func sendRequestWithAPIResponse<T: Decodable>(
        path: String,
        httpMethod: HTTPMethod,
        queryParams: [String: String]? = nil,
        body: APIRequestBody? = nil,
        additionalHeaders: [String: String] = [:]
    ) async throws(APIError) -> (value: T, response: APIResponse) {
        let request = try self.buildRequest(
            path: path,
            method: httpMethod,
            queryParams: queryParams,
            body: body,
            additionalHeaders: additionalHeaders
        )

        var apiResponse: APIResponse?
        apiResponse = try? await self.send(request: request)

        guard
            let apiResponse,
            (200...299).contains(apiResponse.statusCode)
        else {
            throw APIError.networkError(statusCode: apiResponse?.statusCode ?? 400)
        }

        let decodedResponse: T
        do {
            decodedResponse = try self.decodeData(response: apiResponse)
        } catch {
            throw APIError.parsingError(error)
        }
        return (decodedResponse, apiResponse)
    }

    private func buildRequest(
        path: String,
        method: HTTPMethod,
        queryParams: [String: String]? = nil,
        body: APIRequestBody? = nil,
        additionalHeaders: [String: String] = [:],
    ) throws(APIError) -> URLRequest {
        let url = self.baseURL.appendingPathComponent(path)

        guard var urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidRequest
        }

        if let queryParams = queryParams {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = urlComponents.url else {
            throw APIError.invalidRequest
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        var headers: [String: String] = [:]
        do {
            headers = try self.defaultHeaders(additionalHeaders: additionalHeaders)
        } catch {
            throw APIError.invalidRequest
        }
        request.allHTTPHeaderFields = headers

        var contentType: String?
        switch body {
        case .jsonBody(let body):
            let encoder = JSONEncoder()
            request.httpBody = try? encoder.encode(body)
            contentType = "application/json"
        case .urlEncodedBody(let body):
            var components = URLComponents()
            components.queryItems = body.map { URLQueryItem(name: $0.key, value: $0.value) }
            request.httpBody = components.query?.data(using: .utf8)
            contentType = "application/x-www-form-urlencoded"
        case .none:
            break
        }

        if let contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        return request
    }

    private func decodeData<T: Decodable>(response: APIResponse) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: response.data)
    }
}
