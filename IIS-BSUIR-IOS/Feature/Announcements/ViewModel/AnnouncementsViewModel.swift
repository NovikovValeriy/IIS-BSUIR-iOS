//
//  AnnouncementsViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

@Observable
@MainActor
final class AnnouncementsViewModel {
    private let service: any AnnouncementsServiceProtocol

    private(set) var announcements: [Announcement]?
    private(set) var isLoading = false

    init(service: any AnnouncementsServiceProtocol) {
        self.service = service
        self.announcements = service.cachedAnnouncements()
    }

    func load() async {
        guard !isLoading else { return }
        if announcements == nil {
            isLoading = true
        }
        defer { isLoading = false }
        do {
            announcements = try await service.fetchAnnouncements()
        } catch {
            print(error.localizedDescription)
        }
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            announcements = try await service.fetchAnnouncements()
        } catch {
            print(error.localizedDescription)
        }
    }
}
