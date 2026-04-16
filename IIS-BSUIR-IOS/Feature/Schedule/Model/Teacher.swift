//
//  Teacher.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 16.04.26.
//

struct Teacher: Hashable, Identifiable {
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

    var fullName: String {
        [lastName, firstName, middleName].compactMap { $0 }.joined(separator: " ")
    }

    var shortName: String {
        let firstInitial = firstName.first.map { "\($0)." } ?? ""
        let middleInitial = middleName?.first.map { "\($0)." } ?? ""
        return "\(lastName) \(firstInitial)\(middleInitial)"
    }
}
