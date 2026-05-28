//
//  AnnouncementsView.swift
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
        static let shadowRadius: CGFloat = 4
        static let shadowOffsetY: CGFloat = 1
    }
    enum Colors {
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let shadowColor = Color.black.opacity(0.05)
    }
    enum Icons {
        static let empty = "bell.slash"
        static let time = "clock"
        static let room = "mappin"
        static let department = "building.2"
    }
}

struct AnnouncementsView: View {
    @State private var viewModel: AnnouncementsViewModel = Container.shared.announcementsViewModel()

    var body: some View {
        Group {
            if let items = viewModel.announcements {
                if items.isEmpty {
                    emptyView
                } else {
                    list(items)
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
        .navigationTitle("profile.announcements.title".localized())
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var emptyView: some View {
        ContentUnavailableView {
                    Label("announcements.empty.title".localized(), systemImage: Constants.Icons.empty)
                }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
    }

    private func list(_ items: [Announcement]) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(items) { item in
                    AnnouncementCardView(announcement: item)
                        .padding(Constants.Layout.rowInsets)
                }
            }
        }
        .refreshable { await viewModel.refresh() }
    }
}

private struct AnnouncementCardView: View {
    let announcement: Announcement

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.cardSpacing) {
            if let date = announcement.date {
                Text(date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let employee = announcement.employee {
                Text(employee)
                    .font(.body.weight(.semibold))
            }

            if let content = announcement.content {
                Text(content)
                    .font(.body)
            }

            if let start = announcement.startTime, let end = announcement.endTime {
                Label("\(start) – \(end)", systemImage: Constants.Icons.time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let auditory = announcement.auditory {
                Label(auditory, systemImage: Constants.Icons.room)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !announcement.departments.isEmpty {
                Label(announcement.departments.joined(separator: ", "), systemImage: Constants.Icons.department)
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
