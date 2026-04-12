//
//  PenaltyIncentiveDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct PenaltyIncentiveDTO: Decodable {
    let directiveDto: DirectiveDTO
    let id: Int
    let note: String?
    let reason: String?
    let status: String
}

struct DirectiveDTO: Decodable {
    // "dd.MM.yyyy"
    let date: String
    let eventType: String
    let eventTypeName: String
    let id: Int
    let number: String
    let type: String
    let typeName: String
}
