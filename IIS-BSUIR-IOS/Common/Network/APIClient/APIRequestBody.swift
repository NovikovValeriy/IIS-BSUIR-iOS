//
//  APIRequestBody.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

enum APIRequestBody {
    case jsonBody(Encodable)
    case urlEncodedBody([String: String])
}
