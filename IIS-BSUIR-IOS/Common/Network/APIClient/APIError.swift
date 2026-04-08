//
//  APIError.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

enum APIError: Error {
    case networkError(statusCode: Int)
    case invalidResponse
    case invalidRequest
    case storedCredentialsError
    case parsingError(Error)
    case unknown
}
