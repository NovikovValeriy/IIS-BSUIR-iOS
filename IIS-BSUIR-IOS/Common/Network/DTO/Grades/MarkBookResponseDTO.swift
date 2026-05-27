//
//  MarkBookResponseDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct MarkBookResponseDTO: Decodable {
    let averageMark: Double
    let number: String
    let markPages: [String: MarkBookPageDTO]
}

struct MarkBookPageDTO: Decodable {
    let averageMark: Double
    let marks: [MarkDTO]
}

struct MarkDTO: Decodable {
    let commonMark: Double?
    let commonRetakes: Double?
    let credits: Int?
    // "dd.MM.yyyy"
    let date: String?
    let formOfControl: String?
    let fullSubject: String?
    let hours: String?
    let idFormOfControl: Int?
    let idSubject: Int?
    let mark: String?
    let retakesCount: Int?
    let subject: String?
    let teacher: String?
}
