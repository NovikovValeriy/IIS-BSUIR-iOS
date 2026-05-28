//
//  OmissionsView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 28.05.26.
//

import SwiftUI
import Factory

private enum Constants {
    enum Layout {
        static let rowInsets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
        static let cardPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 12
        static let cardSpacing: CGFloat = 6
        static let iconSize: CGFloat = 36
        static let badgePaddingH: CGFloat = 8
        static let badgePaddingV: CGFloat = 3
        static let shadowRadius: CGFloat = 4
        static let shadowOffsetY: CGFloat = 1
    }
    enum Colors {
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let shadowColor = Color.black.opacity(0.05)
    }
    enum Icons {
        static let empty = "doc.text.magnifyingglass"
        static let medical = "cross.case.fill"
        static let application = "doc.text.fill"
        static let order = "building.columns.fill"
        static let military = "shield.fill"
        static let defaultDoc = "doc.fill"
        static let dateRange = "calendar"
        static let note = "note.text"
        static let place = "mappin.and.ellipse"
        static let number = "number"
    }
}

struct OmissionsView: View {
    @State private var viewModel: OmissionsViewModel = Container.shared.omissionsViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            } else if let data = viewModel.data {
                content(data)
            } else {
                emptyView
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("omissions.title".localized())
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private func content(_ data: OmissionsData) -> some View {
        List {
            if let hours = viewModel.currentSemesterHours {
                Section {
                    currentHoursBanner(hours: hours)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(Constants.Layout.rowInsets)
                }
            }

            if !data.faculty.isEmpty {
                Section {
                    Text(data.faculty)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if !viewModel.applications.isEmpty {
                Section("omissions.section.applications".localized()) {
                    ForEach(viewModel.applications) { app in
                        OmissionApplicationCardView(application: app)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(Constants.Layout.rowInsets)
                    }
                }
            }

            if viewModel.semesterGroups.isEmpty && viewModel.applications.isEmpty {
                emptyListRow
            } else {
                ForEach(viewModel.semesterGroups, id: \.term) { group in
                    Section {
                        ForEach(group.documents) { doc in
                            OmissionDocumentCardView(document: doc)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(Constants.Layout.rowInsets)
                        }
                    } header: {
                        semesterHeader(term: group.term, totalHours: group.totalHours)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .refreshable { await viewModel.refresh() }
    }

    private func currentHoursBanner(hours: Int) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(hours > 0 ? Color.red.opacity(0.12) : Color.green.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: hours > 0 ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(hours > 0 ? Color.red : Color.green)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "omissions.current.semester.hours %lld".localized(), hours))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(hours > 0 ? Color.red : Color.primary)
                Text("omissions.title".localized())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(Constants.Layout.cardPadding)
        .background(Constants.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
        .shadow(
            color: Constants.Colors.shadowColor,
            radius: Constants.Layout.shadowRadius,
            x: 0,
            y: Constants.Layout.shadowOffsetY
        )
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("omissions.empty.title".localized(), systemImage: Constants.Icons.empty)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private func semesterHeader(term: Int, totalHours: Int) -> some View {
        HStack {
            Text(String(format: "omissions.semester %lld".localized(), term))
            Spacer()
            Text(String(format: "omissions.hours %lld".localized(), totalHours))
                .font(.caption.weight(.medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(
                    totalHours > 0 ? Color.red.opacity(0.15) : Color.secondary.opacity(0.12),
                    in: Capsule()
                )
                .foregroundStyle(totalHours > 0 ? Color.red : Color.secondary)
        }
        .textCase(nil)
    }

    private var emptyListRow: some View {
        ContentUnavailableView {
            Label("omissions.empty.title".localized(), systemImage: Constants.Icons.empty)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

// MARK: - Application Card

private struct OmissionApplicationCardView: View {
    let application: OmissionApplication

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.cardSpacing) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(application.type)
                        .font(.body.weight(.medium))
                    Text(String(format: "omissions.application.number %lld".localized(), application.number))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                statusBadge(application.status)
            }

            Label(
                "\(application.dateFrom) – \(application.dateTo)",
                systemImage: Constants.Icons.dateRange
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Label(application.placeOfStay, systemImage: Constants.Icons.place)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            if let reason = application.rejectionReason, !reason.isEmpty {
                Text(reason)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Text(String(format: "omissions.application.submitted %@".localized(), application.createdDate))
                .font(.caption2)
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.Layout.cardPadding)
        .background(Constants.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
        .shadow(
            color: Constants.Colors.shadowColor,
            radius: Constants.Layout.shadowRadius,
            x: 0,
            y: Constants.Layout.shadowOffsetY
        )
    }

    private func statusBadge(_ status: String) -> some View {
        let color = statusColor(status)
        return Text(status)
            .font(.caption.weight(.medium))
            .padding(.horizontal, Constants.Layout.badgePaddingH)
            .padding(.vertical, Constants.Layout.badgePaddingV)
            .background(color.opacity(0.15), in: Capsule())
            .foregroundStyle(color)
    }

    private func statusColor(_ status: String) -> Color {
        let lower = status.lowercased()
        if lower.contains("одобрен") { return .green }
        if lower.contains("отклонен") || lower.contains("отказ") { return .red }
        return .orange
    }
}

// MARK: - Document Card

private struct OmissionDocumentCardView: View {
    let document: OmissionDocument

    var body: some View {
        HStack(alignment: .top, spacing: Constants.Layout.cardSpacing) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: Constants.Layout.iconSize, height: Constants.Layout.iconSize)
                Image(systemName: iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: Constants.Layout.cardSpacing) {
                Text(document.name)
                    .font(.body.weight(.medium))

                Label(
                    "\(document.dateFrom) – \(document.dateTo)",
                    systemImage: Constants.Icons.dateRange
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                if let note = document.note, !note.isEmpty {
                    Label(note, systemImage: Constants.Icons.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Constants.Layout.cardPadding)
        .background(Constants.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
        .shadow(
            color: Constants.Colors.shadowColor,
            radius: Constants.Layout.shadowRadius,
            x: 0,
            y: Constants.Layout.shadowOffsetY
        )
    }

    private var iconName: String {
        let lower = document.name.lowercased()
        if lower.contains("мед") || lower.contains("справка") { return Constants.Icons.medical }
        if lower.contains("заявление") { return Constants.Icons.application }
        if lower.contains("приказ") || lower.contains("распоряжение") { return Constants.Icons.order }
        if lower.contains("повестка") { return Constants.Icons.military }
        return Constants.Icons.defaultDoc
    }

    private var iconColor: Color {
        let lower = document.name.lowercased()
        if lower.contains("мед") || lower.contains("справка") { return .green }
        if lower.contains("заявление") { return .blue }
        if lower.contains("приказ") || lower.contains("распоряжение") { return .purple }
        if lower.contains("повестка") { return .orange }
        return .secondary
    }
}
