//
//  DocumentsView.swift
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
        static let pickerHPadding: CGFloat = 16
        static let pickerVPadding: CGFloat = 8
        static let pickerSpacing: CGFloat = 8
        static let pillHPadding: CGFloat = 14
        static let pillVPadding: CGFloat = 7
        static let chipHPadding: CGFloat = 8
        static let chipVPadding: CGFloat = 3
        static let animationDuration: Double = 0.25
    }
    enum Colors {
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let shadowColor = Color.black.opacity(0.05)
        static let statusPrinted = Color.green
        static let statusProcessing = Color.orange
        static let statusRejected = Color.red
    }
    enum Icons {
        static let emptyCertificates = "doc.text"
        static let emptyMarkSheets = "doc.plaintext"
    }
}

struct DocumentsView: View {
    @State private var viewModel: DocumentsViewModel = Container.shared.documentsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            tabPicker
            tabContent
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("profile.certificates.title")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    // MARK: - Tab picker

    private var tabPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Layout.pickerSpacing) {
                tabPill(label: "documents.tab.certificates", tag: 0)
                tabPill(label: "documents.tab.marksheets", tag: 1)
            }
            .padding(.horizontal, Constants.Layout.pickerHPadding)
            .padding(.vertical, Constants.Layout.pickerVPadding)
        }
    }

    private func tabPill(label: LocalizedStringKey, tag: Int) -> some View {
        let isSelected = viewModel.selectedTab == tag
        return Button {
            withAnimation(.easeInOut(duration: Constants.Layout.animationDuration)) {
                viewModel.selectedTab = tag
            }
        } label: {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, Constants.Layout.pillHPadding)
                .padding(.vertical, Constants.Layout.pillVPadding)
                .background(
                    isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tab content

    private var tabContent: some View {
        TabView(selection: Bindable(viewModel).selectedTab) {
            certificatesTab.tag(0)
            markSheetsTab.tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: Constants.Layout.animationDuration), value: viewModel.selectedTab)
    }

    // MARK: - Certificates tab

    private var certificatesTab: some View {
        Group {
            if let items = viewModel.certificates {
                if items.isEmpty {
                    ContentUnavailableView("documents.certificates.empty", systemImage: Constants.Icons.emptyCertificates)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(items) { item in
                                CertificateCardView(certificate: item)
                                    .padding(Constants.Layout.rowInsets)
                            }
                        }
                    }
                    .refreshable { await viewModel.refresh() }
                }
            } else if viewModel.isLoadingCertificates {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ContentUnavailableView("documents.certificates.empty", systemImage: Constants.Icons.emptyCertificates)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Marksheets tab

    private var markSheetsTab: some View {
        Group {
            if let items = viewModel.markSheets {
                if items.isEmpty {
                    ContentUnavailableView("documents.marksheets.empty", systemImage: Constants.Icons.emptyMarkSheets)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(items) { item in
                                MarkSheetCardView(markSheet: item)
                                    .padding(Constants.Layout.rowInsets)
                            }
                        }
                    }
                    .refreshable { await viewModel.refresh() }
                }
            } else if viewModel.isLoadingMarkSheets {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ContentUnavailableView("documents.marksheets.empty", systemImage: Constants.Icons.emptyMarkSheets)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - Certificate Card

private struct CertificateCardView: View {
    let certificate: Certificate

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.cardSpacing) {
            HStack {
                Text(String(format: String(localized: "documents.certificate.number %lld"), certificate.number))
                    .font(.body.weight(.semibold))
                Spacer()
                statusChip
            }

            Text(certificate.type)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(certificate.deliveryPlace)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label(
                    String(format: String(localized: "documents.certificate.ordered %@"), certificate.orderDate),
                    systemImage: "calendar"
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                if let issueDate = certificate.issueDate {
                    Label(
                        String(format: String(localized: "documents.certificate.issued %@"), issueDate),
                        systemImage: "checkmark.circle"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            if let reason = certificate.rejectionReason, !reason.isEmpty {
                Text(reason)
                    .font(.caption)
                    .foregroundStyle(Constants.Colors.statusRejected)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.Layout.cardPadding)
        .background(Constants.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
        .shadow(color: Constants.Colors.shadowColor, radius: Constants.Layout.shadowRadius, x: 0, y: Constants.Layout.shadowOffsetY)
    }

    private var statusChip: some View {
        let (label, color) = statusInfo(certificate.status)
        return Text(label)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, Constants.Layout.chipHPadding)
            .padding(.vertical, Constants.Layout.chipVPadding)
            .background(color.opacity(0.15), in: Capsule())
    }

    private func statusInfo(_ status: CertificateStatus) -> (LocalizedStringKey, Color) {
        switch status {
        case .printed:    return ("documents.status.printed", Constants.Colors.statusPrinted)
        case .processing: return ("documents.status.processing", Constants.Colors.statusProcessing)
        case .rejected:   return ("documents.status.rejected", Constants.Colors.statusRejected)
        case .unknown:    return ("documents.status.processing", Constants.Colors.statusProcessing)
        }
    }
}

// MARK: - MarkSheet Card

private struct MarkSheetCardView: View {
    let markSheet: MarkSheet

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.cardSpacing) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if let number = markSheet.number {
                        Text(String(format: String(localized: "documents.marksheet.number %@"), number))
                            .font(.body.weight(.semibold))
                    }
                    if let typeName = markSheet.typeName {
                        Text(typeName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                statusChip
            }

            if let subjectName = markSheet.subjectName {
                let typeLabel = markSheet.lessonTypeAbbrev.map { " · \($0)" } ?? ""
                Text(subjectName + typeLabel)
                    .font(.subheadline)
            }

            if let teacher = markSheet.teacherFio {
                Label(teacher, systemImage: "person")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                if let absentDate = markSheet.absentDate {
                    Label(
                        String(format: String(localized: "documents.marksheet.absent %@"), absentDate),
                        systemImage: "calendar.badge.exclamationmark"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                if let expireDate = markSheet.expireDate {
                    Label(
                        String(format: String(localized: "documents.marksheet.expires %@"), expireDate),
                        systemImage: "clock"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 8) {
                if markSheet.hours > 0 {
                    badge(
                        String(format: String(localized: "documents.marksheet.hours %@"), formatNumber(markSheet.hours)),
                        color: .secondary
                    )
                }
                if markSheet.retakeCount > 0 {
                    badge(
                        String(format: String(localized: "documents.marksheet.retakes %lld"), markSheet.retakeCount),
                        color: .orange
                    )
                }
                if markSheet.price > 0 {
                    badge(
                        String(format: String(localized: "documents.marksheet.price %@"), formatPrice(markSheet.price)),
                        color: .secondary
                    )
                }
                reasonBadge
            }

            if let reason = markSheet.rejectionReason, !reason.isEmpty {
                Text(reason)
                    .font(.caption)
                    .foregroundStyle(Constants.Colors.statusRejected)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.Layout.cardPadding)
        .background(Constants.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
        .shadow(color: Constants.Colors.shadowColor, radius: Constants.Layout.shadowRadius, x: 0, y: Constants.Layout.shadowOffsetY)
    }

    private var statusChip: some View {
        let color = markSheetStatusColor(markSheet.status)
        return Text(markSheet.status)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, Constants.Layout.chipHPadding)
            .padding(.vertical, Constants.Layout.chipVPadding)
            .background(color.opacity(0.15), in: Capsule())
    }

    private var reasonBadge: some View {
        let key: String.LocalizationValue = markSheet.isRespectful ? "documents.marksheet.excused" : "documents.marksheet.unexcused"
        let color: Color = markSheet.isRespectful ? .green : .red
        return badge(String(localized: key), color: color)
    }

    private func badge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundStyle(color)
            .padding(.horizontal, Constants.Layout.chipHPadding)
            .padding(.vertical, Constants.Layout.chipVPadding)
            .background(color.opacity(0.12), in: Capsule())
    }

    private func markSheetStatusColor(_ status: String) -> Color {
        let lower = status.lowercased()
        if lower.contains("напечат") || lower.contains("готов") { return Constants.Colors.statusPrinted }
        if lower.contains("отклон") || lower.contains("отмен") || lower.contains("закрыт") { return Constants.Colors.statusRejected }
        return Constants.Colors.statusProcessing
    }

    private func formatNumber(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }

    private func formatPrice(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}
