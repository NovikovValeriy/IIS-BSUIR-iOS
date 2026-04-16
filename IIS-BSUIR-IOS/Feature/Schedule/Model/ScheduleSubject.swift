//
//  ScheduleSubject.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 16.04.26.
//

enum ScheduleSubject: Hashable {
    case group(GroupModel)
    // Future cases:
    // case teacher(Teacher)
    // case auditory(String)

    /// Short name shown in the navigation title and pickers (e.g. "153502").
    var displayName: String {
        switch self {
        case .group(let group): return group.name
        }
    }

    /// Secondary descriptor shown below the name in pickers (e.g. speciality abbreviation).
    var subjectDescription: String? {
        switch self {
        case .group(let group): return group.specialityAbbrev
        }
    }
}
