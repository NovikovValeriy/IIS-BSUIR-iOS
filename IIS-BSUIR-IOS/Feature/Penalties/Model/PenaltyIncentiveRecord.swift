//
//  PenaltyIncentiveRecord.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

struct PenaltyIncentiveRecord: Identifiable, Codable {
    let id: Int
    let isPenalty: Bool
    let eventTypeName: String
    let directiveNumber: String
    // "dd.MM.yyyy"
    let date: String
    let status: String
    let note: String?
    let reason: String?
}
