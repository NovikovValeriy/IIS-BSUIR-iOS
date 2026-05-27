//
//  MarkBookView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 21.04.26.
//

import SwiftUI
import Factory

private enum Constants {
    enum Layout {
        static let summaryHorizontalPadding: CGFloat = 16
        static let summaryVerticalPadding: CGFloat = 10
        static let pickerVerticalPadding: CGFloat = 8
        static let pickerHorizontalPadding: CGFloat = 16
        static let pickerSpacing: CGFloat = 8
        static let pillHorizontalPadding: CGFloat = 14
        static let pillVerticalPadding: CGFloat = 7
        static let rowInsets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
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

struct MarkBookView: View {
    @State private var viewModel: MarkBookViewModel = Container.shared.markBookViewModel()

    var body: some View {
        Group {
            if viewModel.markBook != nil {
                loadedView
            } else if viewModel.isLoading {
                ProgressView()
            } else {
                ContentUnavailableView("markbook.empty.title", systemImage: "graduationcap")
            }
        }
        .navigationTitle("markbook.title")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var loadedView: some View {
        VStack(spacing: 0) {
            summaryStrip

            semesterPicker

            TabView(selection: $viewModel.selectedSemesterIndex) {
                ForEach(viewModel.semesters.indices, id: \.self) { index in
                    semesterList(for: viewModel.semesters[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.25), value: viewModel.selectedSemesterIndex)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private var summaryStrip: some View {
        Group {
            if let markBook = viewModel.markBook {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("markbook.number.label")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(markBook.number)
                            .font(.title3.bold())
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("markbook.total.average.label")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(markBook.averageMark.formattedAverage)
                            .font(.title3.bold())
                    }
                }
                .padding(.horizontal, Constants.Layout.summaryHorizontalPadding)
                .padding(.vertical, Constants.Layout.summaryVerticalPadding)
            }
        }
    }

    private var semesterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Layout.pickerSpacing) {
                ForEach(viewModel.semesters.indices, id: \.self) { index in
                    let semester = viewModel.semesters[index]
                    let isSelected = viewModel.selectedSemesterIndex == index
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.selectedSemesterIndex = index
                        }
                    } label: {
                        Text(String(format: String(localized: "markbook.semester.short \(semester.semester)")))
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
    }

    private func semesterList(for semester: MarkBookSemester) -> some View {
        List {
            Section {
                ForEach(semester.marks.indices, id: \.self) { index in
                    MarkRowView(mark: semester.marks[index])
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(Constants.Layout.rowInsets)
                }
            } header: {
                let avgString = semester.averageMark.formattedAverage
                HStack {
                    Text(String(format: String(localized: "markbook.semester \(semester.semester)")))
                    Spacer()
                    Text(String(format: String(localized: "markbook.average \(avgString)")))
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .textCase(nil)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
    }
}
