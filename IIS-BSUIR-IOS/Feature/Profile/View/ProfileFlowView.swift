//
//  ProfileFlowView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct ProfileFlowView: View {
    @State private var router: ProfileRouter = Container.shared.profileRouter()
    @State private var viewModel: ProfileViewModel = Container.shared.profileViewModel()

    var body: some View {
        NavigationStack(path: $router.path) {
            ProfileView()
                .navigationDestination(for: ProfileDestination.self) { destination in
                    switch destination {
                    case .grades:
                        GradesView()
                            .navigationTitle("grades.title")
                    case .notifications:
                        NotificationsView()
                            .navigationTitle("notifications.title")
                    case .dormitory:
                        Text("profile.dormitory.title")
                            .navigationTitle("profile.dormitory.title")
                    case .documents:
                        Text("profile.documents.title")
                            .navigationTitle("profile.documents.title")
                    case .contacts:
                        Text("profile.contacts.title")
                            .navigationTitle("profile.contacts.title")
                    case .changePassword:
                        Text("profile.change_password.title")
                            .navigationTitle("profile.change_password.title")
                    }
                }
        }
        .sheet(item: $router.presentedSheet) { sheet in
            switch sheet {
            case .editProfile:
                Text("profile.edit.coming_soon")
                    .presentationDetents([.large])
            }
        }
        .confirmationDialog(
            "profile.logout_confirmation.title",
            isPresented: Binding(
                get: { router.confirmationDialog != nil },
                set: { if !$0 { router.confirmationDialog = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("profile.logout_confirmation.button", role: .destructive) {
                viewModel.confirmLogout()
            }
            Button("common.cancel", role: .cancel) {}
        }
        .alert(item: $router.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: alert.message.map { Text($0) },
                dismissButton: .default(Text("common.ok"))
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .popToRoot(for: .profile))) { _ in
            router.popToRoot()
        }
    }
}
