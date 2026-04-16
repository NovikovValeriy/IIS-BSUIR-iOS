//
//  ForgotPasswordView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI

private enum Constants {
    enum Icons {
        static let key = "key.fill"
    }
}

struct ForgotPasswordView: View {
    var body: some View {
        ContentUnavailableView(
            "auth.forgot_password.title",
            systemImage: Constants.Icons.key,
            description: Text("auth.forgot_password.description")
        )
        .navigationTitle("auth.forgot_password.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
