//
//  PenaltiesView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import Factory
import SwiftUI

private enum Constants {
    enum Layout {
        static let rowInsets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
        static let cardPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 12
        static let cardSpacing: CGFloat = 6
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
        static let empty = "flag.slash"
        static let date = "calendar"
        static let number = "number"
        static let note = "note.text"
        static let reason = "exclamationmark.circle"
    }
}

struct PenaltiesView: View {
    @State private var viewModel: PenaltiesViewModel = Container.shared.penaltiesViewModel()

    var body: some View {
        Group {
            if let records = viewModel.records {
                if records.isEmpty {
                    emptyView
                } else {
                    list
                }
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            } else {
                emptyView
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("profile.penalties.title".localized())
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var emptyView: some View {
        ContentUnavailableView {
                    Label("penalties.empty.title".localized(), systemImage: Constants.Icons.empty)
                }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
    }

    private var list: some View {
        List {
            if !viewModel.penalties.isEmpty {
                Section("penalties.section.penalties".localized()) {
                    ForEach(viewModel.penalties) { record in
                        PenaltyIncentiveCardView(record: record)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(Constants.Layout.rowInsets)
                    }
                }
            }
            if !viewModel.incentives.isEmpty {
                Section("penalties.section.incentives".localized()) {
                    ForEach(viewModel.incentives) { record in
                        PenaltyIncentiveCardView(record: record)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(Constants.Layout.rowInsets)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .refreshable { await viewModel.refresh() }
    }
}

private struct PenaltyIncentiveCardView: View {
    let record: PenaltyIncentiveRecord

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.cardSpacing) {
            HStack {
                Text(record.eventTypeName)
                    .font(.body.weight(.semibold))
                    .lineLimit(2)
                Spacer(minLength: 8)
                statusBadge(record.status)
            }

            Label(
                String(format: "penalties.directive %@".localized(), record.directiveNumber),
                systemImage: Constants.Icons.number
            )
            .font(.caption)
            .foregroundStyle(.secondary)

            Label(record.date, systemImage: Constants.Icons.date)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let reason = record.reason {
                Label(reason, systemImage: Constants.Icons.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let note = record.note {
                Label(note, systemImage: Constants.Icons.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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
        let lower = status.lowercased()
        let color: Color = lower.contains("снят") || lower.contains("исполнен") ? .green : .orange
        return Text(status)
            .font(.caption.weight(.medium))
            .padding(.horizontal, Constants.Layout.badgePaddingH)
            .padding(.vertical, Constants.Layout.badgePaddingV)
            .background(color.opacity(0.15), in: Capsule())
            .foregroundStyle(color)
    }
}
