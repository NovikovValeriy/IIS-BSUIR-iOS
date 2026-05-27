//
//  ActivityView.swift
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
        static let markSize: CGFloat = 32
        static let markCornerRadius: CGFloat = 7
        static let markSpacing: CGFloat = 4
        static let shadowRadius: CGFloat = 4
        static let shadowOffsetY: CGFloat = 1
    }
    enum Colors {
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let shadowColor = Color.black.opacity(0.05)
        static let lowMark = Color.red.opacity(0.18)
        static let midMark = Color.yellow.opacity(0.28)
        static let highMark = Color.green.opacity(0.18)
        static let omissionBackground = Color.red.opacity(0.18)
        static let respectfulOmissionBackground = Color.orange.opacity(0.18)
    }
    enum Icons {
        static let empty = "chart.line.downtrend.xyaxis"
        static let omission = "exclamationmark.circle.fill"
    }
}

struct ActivityView: View {
    @State private var viewModel: ActivityViewModel = Container.shared.activityViewModel()

    var body: some View {
        Group {
            if let data = viewModel.activityData {
                if data.entries.isEmpty {
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
        .navigationTitle("profile.activity.title")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var emptyView: some View {
        ContentUnavailableView("activity.empty.title", systemImage: Constants.Icons.empty)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
    }

    private func list(_ data: ActivityData) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(data.entries) { entry in
                    ActivityEntryCardView(entry: entry)
                        .padding(Constants.Layout.rowInsets)
                }
            }
        }
        .refreshable { await viewModel.refresh() }
    }
}

// MARK: - Entry Card

private struct ActivityEntryCardView: View {
    let entry: ActivityEntry

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.cardSpacing) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.subjectName)
                        .font(.body.weight(.semibold))
                    if let type = entry.lessonTypeAbbrev {
                        Text(type)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if let date = entry.date {
                    Text(date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !entry.marks.isEmpty {
                marksRow(entry.marks)
            }

            if entry.omissions > 0 {
                omissionsRow(entry.omissions, respectful: entry.isRespectfulOmission)
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

    private func marksRow(_ marks: [Int]) -> some View {
        HStack(spacing: Constants.Layout.markSpacing) {
            ForEach(Array(marks.enumerated()), id: \.offset) { _, mark in
                markView(mark)
            }
            Spacer()
        }
    }

    private func markView(_ value: Int) -> some View {
        let background: Color = {
            if value >= 7 { return Constants.Colors.highMark }
            if value >= 4 { return Constants.Colors.midMark }
            return Constants.Colors.lowMark
        }()
        return Text(value > 0 ? "\(value)" : "—")
            .font(.callout.weight(.semibold))
            .monospacedDigit()
            .frame(width: Constants.Layout.markSize, height: Constants.Layout.markSize)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.markCornerRadius))
    }

    private func omissionsRow(_ hours: Int, respectful: Bool) -> some View {
        let background =
        respectful
        ? Constants.Colors.respectfulOmissionBackground
        : Constants.Colors.omissionBackground

        return Label(
            String(format: String(localized: "activity.omissions %lld"), hours),
            systemImage: Constants.Icons.omission
        )
        .font(.caption.weight(.medium))
        .foregroundStyle(respectful ? Color.orange : Color.red)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(background, in: Capsule())
    }
}
