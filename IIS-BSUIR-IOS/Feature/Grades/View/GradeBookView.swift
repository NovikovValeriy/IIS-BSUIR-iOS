//
//  GradeBookView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 21.04.26.
//

import SwiftUI
import Factory

private enum Constants {
    enum Layout {
        static let pickerVerticalPadding: CGFloat = 10
        static let pickerHorizontalPadding: CGFloat = 16
        static let pickerSpacing: CGFloat = 8
        static let pillHorizontalPadding: CGFloat = 14
        static let pillVerticalPadding: CGFloat = 7
        static let pillCornerRadius: CGFloat = 20
        static let rowInsets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
        static let summaryRowInsets = EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16)
    }
}

struct GradeBookView: View {
    @State private var viewModel: GradeBookViewModel = Container.shared.gradeBookViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.markBook == nil {
                ContentUnavailableView("grades.empty.title", systemImage: "graduationcap")
            } else {
                loadedView
            }
        }
        .navigationTitle("grades.title")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var loadedView: some View {
        VStack(spacing: 0) {
            semesterPicker
            Divider()
            List {
                summaryRow
                marksSection
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var semesterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Layout.pickerSpacing) {
                ForEach(viewModel.semesters.indices, id: \.self) { index in
                    let semester = viewModel.semesters[index]
                    let isSelected = viewModel.selectedSemesterIndex == index
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedSemesterIndex = index
                        }
                    } label: {
                        Text(String(format: String(localized: "grades.semester.short %lld"), semester.semester))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(isSelected ? .white : .primary)
                            .padding(.horizontal, Constants.Layout.pillHorizontalPadding)
                            .padding(.vertical, Constants.Layout.pillVerticalPadding)
                            .background(
                                isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Constants.Layout.pickerHorizontalPadding)
            .padding(.vertical, Constants.Layout.pickerVerticalPadding)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var summaryRow: some View {
        Group {
            if let markBook = viewModel.markBook {
                HStack {
                    Text(String(format: String(localized: "grades.markbook.number %@"), markBook.number))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    let avgString = String(format: "%.1f", markBook.averageMark)
                    Text(String(format: String(localized: "grades.average %@"), avgString))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(Constants.Layout.summaryRowInsets)
    }

    @ViewBuilder
    private var marksSection: some View {
        if let semester = viewModel.currentSemester {
            Section {
                ForEach(semester.marks.indices, id: \.self) { index in
                    MarkRowView(mark: semester.marks[index])
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(Constants.Layout.rowInsets)
                }
            } header: {
                let avgString = String(format: "%.1f", semester.averageMark)
                HStack {
                    Text(String(format: String(localized: "grades.semester %lld"), semester.semester))
                    Spacer()
                    Text(String(format: String(localized: "grades.average %@"), avgString))
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .textCase(nil)
            }
        }
    }
}
