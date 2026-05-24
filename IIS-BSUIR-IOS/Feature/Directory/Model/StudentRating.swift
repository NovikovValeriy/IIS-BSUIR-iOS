//
//  StudentRating.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 24.05.26.
//

struct StudentRating: Identifiable, Codable {
    var id: String { cardNumber }
    let cardNumber: String
    let average: Double
    let omissionHours: Int
}
