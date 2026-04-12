//
//  MainTabView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct MainTabView: View {
    @State private var tabCoordinator: TabCoordinator = Container.shared.tabCoordinator()

    var body: some View {
        TabView(selection: Binding(
            get: { tabCoordinator.selectedTab },
            set: { tabCoordinator.select($0) }
        )) {
            ScheduleFlowView()
                .tabItem { Label(TabItem.schedule.title, systemImage: TabItem.schedule.systemImage) }
                .tag(TabItem.schedule)

            ProfileFlowView()
                .tabItem { Label(TabItem.profile.title, systemImage: TabItem.profile.systemImage) }
                .tag(TabItem.profile)

            SettingsFlowView()
                .tabItem { Label(TabItem.settings.title, systemImage: TabItem.settings.systemImage) }
                .tag(TabItem.settings)
        }
    }
}
