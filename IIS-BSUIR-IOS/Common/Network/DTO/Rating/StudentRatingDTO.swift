//
//  StudentRatingDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 24.05.26.
//

struct StudentRatingDTO: Decodable {
    let studentCardNumber: String
    let average: Double
    let hours: Int
}
