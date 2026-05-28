//
//  OmissionsResponseDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct OmissionsResponseDTO: Decodable {
    let faculty: String?
    let omissionDtoList: [OmissionDTO]?
}

struct OmissionDTO: Decodable {
    let id: Int
    let name: String
    // "yyyy-MM-dd"
    let dateFrom: String
    let dateTo: String
    let note: String?
    let term: Int
}

struct OmissionCountDTO: Decodable {
    let term: Int
    let totalHours: Int
}

struct OmissionApplicationDTO: Decodable {
    let id: Int
    let number: Int
    let status: String
    let omissionCertificateType: String
    // "yyyy-MM-dd"
    let dateFrom: String
    let dateTo: String
    // "yyyy-MM-ddTHH:mm:ss.SSS"
    let createdDate: String
    let placeOfStay: String
    let rejectionReason: String?
}
