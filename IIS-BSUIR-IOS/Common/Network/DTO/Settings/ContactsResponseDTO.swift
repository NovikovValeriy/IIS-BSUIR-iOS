//
//  ContactsResponseDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct ContactsResponseDTO: Decodable {
    let contactDtoList: [ContactDTO]
    let numberOfAttempts: Int
}

struct ContactDTO: Decodable {
    // ISO 8601
    let codeExpirationTime: String?
    let confirmed: Bool
    let contactTypeId: Int
    let contactValue: String
    let id: Int
}
