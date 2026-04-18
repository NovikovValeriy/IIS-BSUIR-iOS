//
//  SearchScheduleView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 17.04.26.
//

import SwiftUI

private enum Constants {
    enum Icons {
        static let search = "magnifyingglass"
        static let pin = "bookmark"
        static let pinFill = "bookmark.fill"
    }
}

struct SearchScheduleView: View {
    @Bindable var viewModel: SearchScheduleViewModel

    var body: some View {
        ScheduleView(viewModel: viewModel) {
            noSubjectView
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.didTapSelectGroup()
                } label: {
                    Image(systemName: Constants.Icons.search)
                }
            }
            if viewModel.selectedSubject != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.didTapPin()
                    } label: {
                        Image(systemName: viewModel.isPinned ? Constants.Icons.pinFill : Constants.Icons.pin)
                    }
                }
            }
        }
    }

    private var noSubjectView: some View {
        ContentUnavailableView {
            Label("schedule.no_subject.title", systemImage: Constants.Icons.search)
        } description: {
            Text("schedule.no_subject.description")
        } actions: {
            Button("schedule.select_subject.action") {
                viewModel.didTapSelectGroup()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
