//
//  StorageProtocol.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 17.04.26.
//

import Foundation

protocol StorageProtocol: AnyObject {
    func value<T: Codable>(for key: StorageKey) -> T?
    func setValue<T: Codable>(_ value: T, for key: StorageKey)
    func removeValue(for key: StorageKey)
}

enum StorageKey: String {
    case pinnedScheduleSubject
    case scheduleDisplayMode
    case scheduleSubgroupFilter
    case currentSemesterWeek
    case groupNumber
}
