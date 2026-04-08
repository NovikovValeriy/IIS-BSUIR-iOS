//
//  AccountProfileDTO.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 9.04.26.
//

struct AccountProfileDTO: Codable {
    let birthDate: String?
    let course: Int?
    let faculty: String?
    let firstName: String?
    let id: Int?
    let lastName: String?
    let middleName: String?
    let officeEmail: String?
    let officePassword: String?
    let photoUrl: String?
    let rating: Int?
    let references: [ProfileReferenceDTO]?
    let published: Bool?
    let searchJob: Bool?
    let showRating: Bool?
    let skills: [ProfileSkillDTO]?
    let speciality: String?
    let studentGroup: String?
    let summary: String?
}
