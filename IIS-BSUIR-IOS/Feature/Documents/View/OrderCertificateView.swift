//
//  OrderCertificateView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Factory
import SwiftUI

private enum Constants {
    enum Layout {
        static let stepperRange = 1...10
    }
}

struct OrderCertificateView: View {
    let onOrderPlaced: () async -> Void

    @State private var viewModel = Container.shared.orderCertificateViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            form
                .navigationTitle("documents.certificate.order.title")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("common.cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        if viewModel.isSubmitting {
                            ProgressView()
                        } else {
                            Button("documents.certificate.order.submit") {
                                Task { await viewModel.submit() }
                            }
                            .disabled(!viewModel.canSubmit)
                        }
                    }
                }
                .task { await viewModel.load() }
                .onChange(of: viewModel.didSucceed) { _, succeeded in
                    guard succeeded else { return }
                    dismiss()
                    Task { await onOrderPlaced() }
                }
        }
    }

    @ViewBuilder
    private var form: some View {
        if viewModel.isLoadingPlaces {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Form {
                typeSection
                placeSection
                countSection
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
        }
    }

    private var typeSection: some View {
        Section("documents.certificate.order.type") {
            Picker("documents.certificate.order.type", selection: Binding(
                get: { viewModel.selectedType ?? "" },
                set: { viewModel.didSelectType($0) }
            )) {
                ForEach(viewModel.placeCategories, id: \.type) { category in
                    Text(category.type).tag(category.type)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    }

    private var placeSection: some View {
        Section("documents.certificate.order.place") {
            Picker("documents.certificate.order.place", selection: Binding(
                get: { viewModel.selectedPlace ?? "" },
                set: { viewModel.selectedPlace = $0 }
            )) {
                ForEach(viewModel.availablePlaces) { place in
                    Text(place.name).tag(place.name)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .disabled(viewModel.availablePlaces.isEmpty)
        }
    }

    private var countSection: some View {
        Section("documents.certificate.order.count") {
            Stepper(
                String(format: String(localized: "documents.certificate.order.count.value %lld"), viewModel.count),
                value: Bindable(viewModel).count,
                in: Constants.Layout.stepperRange
            )
        }
    }
}
