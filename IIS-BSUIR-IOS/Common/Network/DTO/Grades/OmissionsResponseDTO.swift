//
//  OmissionsResponseDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct OmissionsResponseDTO: Decodable {
    let faculty: String
    let omissionDtoList: [OmissionDTO]
}

struct OmissionDTO: Decodable {
    // "yyyy-MM-dd"
    let dateFrom: String
    let dateTo: String
    let id: Int
    let name: String
    let note: String?
    let term: String
}
