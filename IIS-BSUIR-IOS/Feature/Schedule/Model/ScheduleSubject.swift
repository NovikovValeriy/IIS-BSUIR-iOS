//
//  ScheduleSubject.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 16.04.26.
//

enum ScheduleSubject: Hashable {
    case group(GroupModel)
    case teacher(Teacher)
    // Future cases:
    // case auditory(String)

    /// Short name shown in the navigation title and pickers.
    var displayName: String {
        switch self {
        case .group(let group): return group.name
        case .teacher(let teacher): return teacher.shortName
        }
    }

    /// Secondary descriptor shown below the name in pickers.
    var subjectDescription: String? {
        switch self {
        case .group(let group): return group.specialityAbbrev
        case .teacher(let teacher): return teacher.rank
        }
    }
}
