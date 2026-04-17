//
//  PinnedScheduleService.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 17.04.26.
//

import Foundation
import Observation

protocol PinnedScheduleServiceProtocol: AnyObject {
    var subject: ScheduleSubject? { get }
    func save(_ subject: ScheduleSubject)
    func clear()
}

@Observable
@MainActor
final class PinnedScheduleService: PinnedScheduleServiceProtocol {
    private let storage: any StorageProtocol

    private(set) var subject: ScheduleSubject?

    init(storage: any StorageProtocol) {
        self.storage = storage
        self.subject = storage.value(for: .pinnedScheduleSubject)
    }

    func save(_ subject: ScheduleSubject) {
        self.subject = subject
        storage.setValue(subject, for: .pinnedScheduleSubject)
    }

    func clear() {
        self.subject = nil
        storage.removeValue(for: .pinnedScheduleSubject)
    }
}
