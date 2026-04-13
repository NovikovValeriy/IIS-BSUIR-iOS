//
//  AuthFlowView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct AuthFlowView: View {
    @State private var router: AuthRouter = Container.shared.authRouter()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack(path: $router.path) {
            LoginView()
                .navigationDestination(for: AuthDestination.self) { destination in
                    switch destination {
                    case .forgotPassword:
                        ForgotPasswordView()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("common.cancel") { dismiss() }
                    }
                }
        }
        .sheet(item: $router.presentedSheet) { sheet in
            switch sheet {
            case .confirmContact:
                Text("auth.confirm_contact.coming_soon")
                    .presentationDetents([.medium])
            }
        }
        .alert(item: $router.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: alert.message.map { Text($0) },
                dismissButton: .default(Text("common.ok"))
            )
        }
    }
}
