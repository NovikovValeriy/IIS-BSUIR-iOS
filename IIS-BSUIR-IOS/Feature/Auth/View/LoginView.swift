//
//  LoginView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

struct LoginView: View {
    @State private var viewModel: LoginViewModel = Container.shared.loginViewModel()

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("IIS BSUIR")
                .font(.largeTitle.bold())

            VStack(spacing: 16) {
                TextField("Username", text: $viewModel.username)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)

                Toggle("Remember device", isOn: $viewModel.rememberDevice)
            }
            .padding(.horizontal)

            Button {
                Task { await viewModel.login() }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Sign In")
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSubmit)
            .padding(.horizontal)

            Button("Forgot password?") {
                viewModel.didTapForgotPassword()
            }
            .font(.footnote)

            Spacer()
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
    }
}
