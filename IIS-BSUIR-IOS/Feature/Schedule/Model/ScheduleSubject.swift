//
//  ScheduleSubject.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 16.04.26.
//

enum ScheduleSubject: Hashable, Codable {
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

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey { case type, group, teacher }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "group":
            self = .group(try container.decode(GroupModel.self, forKey: .group))
        case "teacher":
            self = .teacher(try container.decode(Teacher.self, forKey: .teacher))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown type '\(type)'"
            )
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .group(let group):
            try container.encode("group", forKey: .type)
            try container.encode(group, forKey: .group)
        case .teacher(let teacher):
            try container.encode("teacher", forKey: .type)
            try container.encode(teacher, forKey: .teacher)
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
