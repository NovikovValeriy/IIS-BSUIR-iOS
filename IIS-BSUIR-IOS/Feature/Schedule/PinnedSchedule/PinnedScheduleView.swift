//
//  PinnedScheduleView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 17.04.26.
//

import SwiftUI

private enum Constants {
    enum Icons {
        static let noPinned = "bookmark.slash"
    }
}

struct PinnedScheduleView: View {
    var viewModel: PinnedScheduleViewModel

    var body: some View {
        ScheduleView(viewModel: viewModel) {
            noPinnedSubjectView
        }
    }

    private var noPinnedSubjectView: some View {
        ContentUnavailableView {
            Label("schedule.pinned.empty.title".localized(), systemImage: Constants.Icons.noPinned)
        } description: {
            Text("schedule.pinned.empty.description".localized())
        }
    }
}
