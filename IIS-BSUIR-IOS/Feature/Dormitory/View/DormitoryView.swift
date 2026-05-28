//
//  DormitoryView.swift
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
        static let empty = "house.slash"
        static let queue = "list.number"
        static let room = "door.right.hand.closed"
        static let calendar = "calendar"
        static let privilege = "star.circle"
        static let year = "clock.badge.checkmark"
        static let note = "note.text"
    }
}

struct DormitoryView: View {
    @State private var viewModel: DormitoryViewModel = Container.shared.dormitoryViewModel()

    var body: some View {
        Group {
            if let data = viewModel.data {
                if data.applications.isEmpty && data.privileges.isEmpty {
                    emptyView
                } else {
                    list(data)
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
        .navigationTitle("profile.dormitory.title".localized())
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var emptyView: some View {
        ContentUnavailableView {
                    Label("dormitory.empty.title".localized(), systemImage: Constants.Icons.empty)
                }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
    }

    private func list(_ data: DormitoryData) -> some View {
        List {
            if !data.applications.isEmpty {
                Section("dormitory.section.applications".localized()) {
                    ForEach(data.applications) { app in
                        DormitoryApplicationCardView(application: app)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(Constants.Layout.rowInsets)
                    }
                }
            }
            if !data.privileges.isEmpty {
                Section("dormitory.section.privileges".localized()) {
                    ForEach(data.privileges) { priv in
                        DormitoryPrivilegeCardView(privilege: priv)
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

private struct DormitoryApplicationCardView: View {
    let application: DormitoryApplication

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.cardSpacing) {
            HStack {
                Text(String(format: "dormitory.application_number %lld".localized(), application.number))
                    .font(.headline)
                Spacer()
                statusBadge(application.status)
            }

            if let queue = application.numberInQueue {
                Label(
                    String(format: "dormitory.queue_position %lld".localized(), queue),
                    systemImage: Constants.Icons.queue
                )
                .font(.subheadline)
            }

            if let room = application.roomInfo {
                Label(room, systemImage: Constants.Icons.room)
                    .font(.subheadline)
            }

            if let date = application.applicationDate {
                Label(
                    String(format: "dormitory.applied %@".localized(), date),
                    systemImage: Constants.Icons.calendar
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            if let settled = application.settledDate {
                Label(
                    String(format: "dormitory.settled %@".localized(), settled),
                    systemImage: Constants.Icons.calendar
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            if let reason = application.rejectionReason {
                Text(reason)
                    .font(.caption)
                    .foregroundStyle(.red)
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
        if lower.contains("заселён") || lower.contains("одобрен") { return .green }
        if lower.contains("отклонён") || lower.contains("отказ") { return .red }
        return .orange
    }
}

private struct DormitoryPrivilegeCardView: View {
    let privilege: DormitoryPrivilege

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.cardSpacing) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(privilege.categoryName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(privilege.privilegeName)
                        .font(.body)
                }
                Spacer()
                Label(String(privilege.year), systemImage: Constants.Icons.year)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let note = privilege.note {
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
}
