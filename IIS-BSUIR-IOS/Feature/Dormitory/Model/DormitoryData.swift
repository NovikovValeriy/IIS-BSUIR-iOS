//
//  DormitoryData.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

struct DormitoryData: Codable {
    let applications: [DormitoryApplication]
    let privileges: [DormitoryPrivilege]
}

struct DormitoryApplication: Identifiable, Codable {
    let id: Int
    let number: Int
    let numberInQueue: Int?
    let status: String
    let roomInfo: String?
    let applicationDate: String?
    let acceptedDate: String?
    let settledDate: String?
    let rejectionReason: String?
}

struct DormitoryPrivilege: Identifiable, Codable {
    let id: Int
    let categoryName: String
    let privilegeName: String
    let note: String?
    let year: Int
}
