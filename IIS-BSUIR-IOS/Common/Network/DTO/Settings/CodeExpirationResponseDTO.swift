//
//  CodeExpirationResponseDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct CodeExpirationResponseDTO: Decodable {
    // ISO 8601
    let codeExpiredTime: String
}
