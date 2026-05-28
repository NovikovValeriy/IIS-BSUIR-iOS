//
//  OmissionsData.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 28.05.26.
//

import Foundation

struct OmissionsData: Codable {
    let faculty: String
    let documents: [OmissionDocument]
    let applications: [OmissionApplication]
    let semesterCounts: [OmissionSemesterCount]
}

struct OmissionSemesterCount: Codable {
    let term: Int
    let totalHours: Int
}

struct OmissionDocument: Codable, Identifiable {
    let id: Int
    let name: String
    let dateFrom: String
    let dateTo: String
    let note: String?
    let term: Int
}

struct OmissionApplication: Codable, Identifiable {
    let id: Int
    let number: Int
    let status: String
    let type: String
    let dateFrom: String
    let dateTo: String
    let createdDate: String
    let placeOfStay: String
    let rejectionReason: String?
}
