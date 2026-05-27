//
//  DocumentsViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

@Observable
@MainActor
final class DocumentsViewModel {
    private let service: any DocumentsServiceProtocol

    private(set) var certificates: [Certificate]?
    private(set) var markSheets: [MarkSheet]?
    private(set) var isLoadingCertificates = false
    private(set) var isLoadingMarkSheets = false
    var selectedTab: Int = 0
    var isShowingOrderSheet = false

    init(service: any DocumentsServiceProtocol) {
        self.service = service
        self.certificates = service.cachedCertificates()
        self.markSheets = service.cachedMarkSheets()
    }

    func load() async {
        await loadCertificates()
        await loadMarkSheets()
    }

    func refresh() async {
        isLoadingCertificates = true
        isLoadingMarkSheets = true
        defer {
            isLoadingCertificates = false
            isLoadingMarkSheets = false
        }
        do {
            certificates = try await service.fetchCertificates()
        } catch {
            print(error.localizedDescription)
        }
        do {
            markSheets = try await service.fetchMarkSheets()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func loadCertificates() async {
        guard !isLoadingCertificates else { return }
        if certificates == nil { isLoadingCertificates = true }
        defer { isLoadingCertificates = false }
        do {
            certificates = try await service.fetchCertificates()
        } catch {
            print("[DocumentsViewModel] certificates error: \(error)")
        }
    }

    func refreshAfterOrder() async {
        do {
            certificates = try await service.fetchCertificates()
        } catch {
            print("[DocumentsViewModel] refresh after order error: \(error)")
        }
    }

    private func loadMarkSheets() async {
        guard !isLoadingMarkSheets else { return }
        if markSheets == nil { isLoadingMarkSheets = true }
        defer { isLoadingMarkSheets = false }
        do {
            markSheets = try await service.fetchMarkSheets()
        } catch {
            print("[DocumentsViewModel] marksheets error: \(error)")
        }
    }
}
