//
//  LinkedScheduleView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 18.04.26.
//

import SwiftUI
import Factory

struct LinkedScheduleView: View {
    @State private var viewModel: LinkedScheduleViewModel

    init(subject: ScheduleSubject, router: ScheduleRouter) {
        _viewModel = State(initialValue: LinkedScheduleViewModel(
            subject: subject,
            router: router,
            scheduleService: Container.shared.scheduleService(),
            cacheService: Container.shared.scheduleCacheService()
        ))
    }

    var body: some View {
        ScheduleView(viewModel: viewModel) {
            EmptyView()
        }
    }
}
