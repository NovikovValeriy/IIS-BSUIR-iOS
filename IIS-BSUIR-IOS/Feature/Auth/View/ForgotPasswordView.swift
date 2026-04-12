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
            "Forgot Password",
            systemImage: "key.fill",
            description: Text("Password reset is not yet implemented.")
        )
        .navigationTitle("Forgot Password")
        .navigationBarTitleDisplayMode(.inline)
    }
}
