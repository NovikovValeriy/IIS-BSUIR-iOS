//
//  ScheduledNotificationsView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 27.05.26.
//

import SwiftUI
import Factory

private enum Constants {
    enum Layout {
        static let cardPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        static let shadowOffsetY: CGFloat = 1
        static let rowInsets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
        static let contentSpacing: CGFloat = 4
        static let metaSpacing: CGFloat = 2
    }
    enum Colors {
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let shadowColor = Color.black.opacity(0.05)
    }
    enum Icons {
        static let empty = "bell.slash"
        static let weekly = "repeat"
        static let once = "1.circle"
        static let clock = "clock"
    }
}

struct ScheduledNotificationsView: View {
    @State private var viewModel: ScheduledNotificationsViewModel = Container.shared.scheduledNotificationsViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.notifications.isEmpty {
                ContentUnavailableView(
                    "notifications.empty.title",
                    systemImage: Constants.Icons.empty,
                    description: Text("notifications.empty.description".localized())
                )
            } else {
                list
            }
        }
        .navigationTitle("notifications.title".localized())
        .task {
            await viewModel.load()
        }
    }

    private var onceNotifications: [ScheduledLessonNotification] {
        viewModel.notifications.filter { !$0.isWeekly }.sorted { $0.title < $1.title }
    }

    private var weeklyNotifications: [ScheduledLessonNotification] {
        viewModel.notifications.filter { $0.isWeekly }.sorted { $0.title < $1.title }
    }

    private var list: some View {
        List {
            if !onceNotifications.isEmpty {
                Section("notifications.section.once".localized()) {
                    ForEach(onceNotifications) { notification in
                        notificationCard(notification)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(Constants.Layout.rowInsets)
                    }
                    .onDelete { indexSet in
                        Task {
                            for index in indexSet {
                                await viewModel.cancel(id: onceNotifications[index].id)
                            }
                        }
                    }
                }
            }
            if !weeklyNotifications.isEmpty {
                Section("notifications.section.weekly".localized()) {
                    ForEach(weeklyNotifications) { notification in
                        notificationCard(notification)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(Constants.Layout.rowInsets)
                    }
                    .onDelete { indexSet in
                        Task {
                            for index in indexSet {
                                await viewModel.cancel(id: weeklyNotifications[index].id)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
    }

    private func notificationCard(_ notification: ScheduledLessonNotification) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Rectangle()
                .fill(notification.isWeekly ? Color.blue : Color.orange)
                .frame(width: 6)

            VStack(alignment: .leading, spacing: Constants.Layout.contentSpacing) {
                Text(notification.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Text(notification.body)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: Constants.Layout.metaSpacing) {
                    Label(notification.triggerTime, systemImage: Constants.Icons.clock)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Label(
                        (notification.isWeekly ? "notifications.weekly" : "notifications.once").localized(),
                        systemImage: notification.isWeekly
                            ? Constants.Icons.weekly
                            : Constants.Icons.once
                    )
                    .font(.caption2)
                    .foregroundStyle(notification.isWeekly ? .blue : .orange)
                }
            }
            .padding(Constants.Layout.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Constants.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
        .shadow(
            color: Constants.Colors.shadowColor,
            radius: Constants.Layout.shadowRadius,
            y: Constants.Layout.shadowOffsetY
        )
    }
}
