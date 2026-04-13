//
//  ForgotPasswordView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI

struct ForgotPasswordView: View {
    var body: some View {
        ContentUnavailableView(
            "auth.forgot_password.title",
            systemImage: "key.fill",
            description: Text("auth.forgot_password.description")
        )
        .navigationTitle("auth.forgot_password.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
