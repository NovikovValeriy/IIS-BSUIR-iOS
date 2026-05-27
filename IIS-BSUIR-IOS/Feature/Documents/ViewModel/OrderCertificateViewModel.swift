//
//  OrderCertificateViewModel.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Foundation

@Observable
@MainActor
final class OrderCertificateViewModel {
    private let service: any DocumentsServiceProtocol

    private(set) var placeCategories: [CertificatePlaceCategory] = []
    private(set) var isLoadingPlaces = false
    private(set) var isSubmitting = false
    private(set) var didSucceed = false
    private(set) var errorMessage: String?

    var selectedType: String?
    var selectedPlace: String?
    var count: Int = 1

    var availablePlaces: [CertificatePlace] {
        placeCategories.first { $0.type == selectedType }?.places ?? []
    }

    var canSubmit: Bool {
        selectedType != nil && selectedPlace != nil && !isSubmitting && !isLoadingPlaces
    }

    init(service: any DocumentsServiceProtocol) {
        self.service = service
    }

    func load() async {
        guard !isLoadingPlaces else { return }
        isLoadingPlaces = true
        defer { isLoadingPlaces = false }
        do {
            placeCategories = try await service.fetchCertificatePlaces()
            if let first = placeCategories.first {
                selectedType = first.type
                selectedPlace = first.places.first?.name
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func didSelectType(_ type: String) {
        selectedType = type
        selectedPlace = placeCategories.first { $0.type == type }?.places.first?.name
    }

    func submit() async {
        guard let type = selectedType, let place = selectedPlace else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }
        do {
            try await service.orderCertificate(type: type, place: place, count: count)
            didSucceed = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
