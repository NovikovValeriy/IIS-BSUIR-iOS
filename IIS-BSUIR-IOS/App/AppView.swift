//
//  AppView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct AppView: View {
    @State private var appCoordinator: AppCoordinator = Container.shared.appCoordinator()
    @State private var themeService: AppThemeService = Container.shared.appThemeService()

    var body: some View {
        MainTabView()
            .fullScreenCover(isPresented: $appCoordinator.isShowingAuth) {
                AuthFlowView()
            }
            .onOpenURL { url in
                appCoordinator.handleDeepLink(url)
            }
            .task {
                await appCoordinator.validateSession()
            }
            .preferredColorScheme(themeService.current.colorScheme)
    }
}
