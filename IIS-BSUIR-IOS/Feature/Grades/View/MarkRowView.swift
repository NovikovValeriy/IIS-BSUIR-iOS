//
//  MarkRowView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 21.04.26.
//

import SwiftUI

private enum Constants {
    enum Layout {
        static let cardPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        static let shadowOffsetY: CGFloat = 1
        static let contentSpacing: CGFloat = 4
        static let footerSpacing: CGFloat = 8
    }
    enum Colors {
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let shadowColor = Color.black.opacity(0.05)
    }
}

private extension Double {
    var formattedAverage: String {
        var result = String(format: "%.2f", self)
        while result.hasSuffix("0") { result.removeLast() }
        if result.hasSuffix(".") { result.removeLast() }
        return result
    }
}

struct MarkRowView: View {
    let mark: Mark

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            mainRow
                .padding(Constants.Layout.cardPadding)

            if mark.commonMark != nil || mark.commonRetakes != nil {
                Divider()
                    .padding(.horizontal, Constants.Layout.cardPadding)

                footerRow
                    .padding(.horizontal, Constants.Layout.cardPadding)
                    .padding(.vertical, Constants.Layout.footerSpacing)
            }
        }
        .background(Constants.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius))
        .shadow(
            color: Constants.Colors.shadowColor,
            radius: Constants.Layout.shadowRadius,
            x: 0,
            y: Constants.Layout.shadowOffsetY
        )
    }

    private var mainRow: some View {
        HStack(alignment: .center, spacing: Constants.Layout.cardPadding) {
            VStack(alignment: .leading, spacing: Constants.Layout.contentSpacing) {
                Text(mark.subject)
                    .font(.headline)

                formControlLine

                if let teacher = mark.teacher {
                    Text(teacher)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let date = mark.date {
                    Text(date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(mark.mark ?? String(localized: "grades.no_mark"))
                    .font(.title.bold())
                    .foregroundStyle(markColor)

                if mark.retakesCount > 0 {
                    Text(String(format: String(localized: "grades.retakes %lld"), mark.retakesCount))
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    @ViewBuilder
    private var formControlLine: some View {
        let parts: [String] = [
            mark.formOfControl,
            mark.hours.map { String(format: String(localized: "grades.hours %@"), $0) },
            mark.credits.map { String(format: String(localized: "grades.credits %lld"), $0) }
        ].compactMap { $0 }

        if !parts.isEmpty {
            Text(parts.joined(separator: ", "))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var footerRow: some View {
        HStack {
            Text("grades.footer.label")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Group {
                let avgPart = mark.commonMark.map { $0.formattedAverage }
                let retakesPart = mark.commonRetakes.map { pct -> String in
                    let pctStr = pct.truncatingRemainder(dividingBy: 1) == 0
                        ? String(format: "%.0f", pct)
                        : String(format: "%.1f", pct)
                    return String(format: String(localized: "grades.footer.retakes %@"), pctStr)
                }

                switch (avgPart, retakesPart) {
                case let (avg?, retakes?):
                    Text("\(avg), \(retakes)")
                case let (avg?, nil):
                    Text(avg)
                case let (nil, retakes?):
                    Text(retakes)
                default:
                    EmptyView()
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var markColor: Color {
        guard let markStr = mark.mark else { return .secondary }
        switch markStr.lowercased() {
        case "зач": return .green
        case "незач", "на", "нд": return .red
        default: break
        }
        guard let numericMark = Double(markStr), let common = mark.commonMark else { return .secondary }
        return numericMark >= common ? .green : .red
    }
}
