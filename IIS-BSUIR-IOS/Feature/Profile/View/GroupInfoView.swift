//
//  GroupInfoView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 25.05.26.
//

import SwiftUI
import Factory
import UIKit

private enum Constants {
    enum Layout {
        static let rowInsets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
        static let cardPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 12
        static let cardSpacing: CGFloat = 4
        static let rankMinWidth: CGFloat = 36
        static let shadowRadius: CGFloat = 4
        static let shadowOffsetY: CGFloat = 1
        static let cardHSpacing: CGFloat = 8
        static let contactSpacing: CGFloat = 14
        static let curatorInsets = EdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16)
    }
    enum Colors {
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let shadowColor = Color.black.opacity(0.05)
    }
    enum Icons {
        static let phone = "phone.fill"
        static let email = "envelope.fill"
        static let empty = "person.3"
        static let copy = "doc.on.doc"
    }
}

struct GroupInfoView: View {
    @State private var viewModel: GroupInfoViewModel = Container.shared.groupInfoViewModel()
    @State private var isRefreshing = false

    var body: some View {
        Group {
            if let info = viewModel.groupInfo {
                list(info: info)
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            } else {
                ContentUnavailableView {
                    Label("group_info.empty.title".localized(), systemImage: Constants.Icons.empty)
                }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(viewModel.groupNumber.map {
            String(format: "group_info.group_number %@".localized(), $0)
        } ?? "profile.group_info.title".localized())
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private func list(info: GroupInfo) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                curatorSection(info.curator)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Constants.Layout.curatorInsets)

                ForEach(Array(info.students.enumerated()), id: \.element.id) { index, student in
                    StudentGroupRowView(rank: index + 1, student: student)
                        .padding(Constants.Layout.rowInsets)
                }
            }
        }
        .refreshable {
            isRefreshing = true
            await viewModel.refresh()
            isRefreshing = false
        }
    }

    private func curatorSection(_ curator: GroupCurator) -> some View {
        VStack(alignment: .leading, spacing: Constants.Layout.contactSpacing) {
            Text("group_info.curator.title".localized())
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(curator.fio)
                .font(.body.weight(.semibold))

            if !curator.phone.isEmpty,
               let url = URL(string: "tel:\(curator.phone.filter { !$0.isWhitespace })") {
                Button {
                    UIApplication.shared.open(url)
                } label: {
                    Label(curator.phone, systemImage: Constants.Icons.phone)
                        .font(.body)
                }
                .buttonStyle(.borderless)
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = curator.phone
                    } label: {
                        Label("common.copy".localized(), systemImage: Constants.Icons.copy)
                    }
                }
            }

            if !curator.email.isEmpty,
               let url = URL(string: "mailto:\(curator.email)") {
                Button {
                    UIApplication.shared.open(url)
                } label: {
                    Label(curator.email, systemImage: Constants.Icons.email)
                        .font(.body)
                }
                .buttonStyle(.borderless)
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = curator.email
                    } label: {
                        Label("common.copy".localized(), systemImage: Constants.Icons.copy)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct StudentGroupRowView: View {
    let rank: Int
    let student: GroupStudent

    var body: some View {
        HStack(alignment: .center, spacing: Constants.Layout.cardHSpacing) {
            Text("#\(rank)")
                .font(.callout.weight(.bold))
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .lineLimit(1)
                .frame(minWidth: Constants.Layout.rankMinWidth, alignment: .leading)

            VStack(alignment: .leading, spacing: Constants.Layout.cardSpacing) {
                Text(student.fio)
                    .font(.body)
                    .lineLimit(2)

                if let position = student.position {
                    Text(position)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
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
}
