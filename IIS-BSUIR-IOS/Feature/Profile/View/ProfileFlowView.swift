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
                            .navigationTitle("Grades")
                    case .notifications:
                        NotificationsView()
                            .navigationTitle("Notifications")
                    case .dormitory:
                        Text("Dormitory")
                            .navigationTitle("Dormitory")
                    case .documents:
                        Text("Documents")
                            .navigationTitle("Documents")
                    case .contacts:
                        Text("Contacts")
                            .navigationTitle("Contacts")
                    case .changePassword:
                        Text("Change Password")
                            .navigationTitle("Change Password")
                    }
                }
        }
        .sheet(item: $router.presentedSheet) { sheet in
            switch sheet {
            case .editProfile:
                Text("Edit profile — coming soon")
                    .presentationDetents([.large])
            }
        }
        .confirmationDialog(
            "Are you sure you want to log out?",
            isPresented: Binding(
                get: { router.confirmationDialog != nil },
                set: { if !$0 { router.confirmationDialog = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Log out", role: .destructive) {
                viewModel.confirmLogout()
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert(item: $router.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: alert.message.map { Text($0) },
                dismissButton: .default(Text("OK"))
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .popToRoot(for: .profile))) { _ in
            router.popToRoot()
        }
    }
}
