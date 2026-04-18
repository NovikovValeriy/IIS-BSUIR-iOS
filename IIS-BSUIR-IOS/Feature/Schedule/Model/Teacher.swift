//
//  Teacher.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 16.04.26.
//

struct Teacher: Hashable, Identifiable, Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let middleName: String?
    let photoLink: String?
    let degree: String?
    let degreeAbbrev: String?
    let rank: String?
    let email: String?
    let urlId: String
    let calendarId: String?
    let jobPositions: String?

    private enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, middleName, photoLink
        case degree, degreeAbbrev, rank, email, urlId, calendarId, jobPositions
    }

    var fullName: String {
        [lastName, firstName, middleName].compactMap { $0 }.joined(separator: " ")
    }

    var shortName: String {
        let firstInitial = firstName.first.map { "\($0)." } ?? ""
        let middleInitial = middleName?.first.map { "\($0)." } ?? ""
        return "\(lastName) \(firstInitial)\(middleInitial)"
    }
}
