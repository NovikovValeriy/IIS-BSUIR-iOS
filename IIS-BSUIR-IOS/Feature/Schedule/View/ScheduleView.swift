//
//  ScheduleView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct ScheduleView: View {
    @State private var viewModel: ScheduleViewModel = Container.shared.scheduleViewModel()

    var body: some View {
        ContentUnavailableView(
            "Schedule",
            systemImage: "calendar",
            description: Text("Schedule screen coming soon.")
        )
        .navigationTitle("Schedule")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.didTapFilter) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
}
