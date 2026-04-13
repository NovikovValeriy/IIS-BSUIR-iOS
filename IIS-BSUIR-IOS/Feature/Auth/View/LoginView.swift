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

            Text("auth.title")
                .font(.largeTitle.bold())

            VStack(spacing: 16) {
                TextField("auth.username.placeholder", text: $viewModel.username)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)

                SecureField("auth.password.placeholder", text: $viewModel.password)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)

                Toggle("auth.remember_device", isOn: $viewModel.rememberDevice)
            }
            .padding(.horizontal)

            Button {
                Task { await viewModel.login() }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("auth.sign_in.button")
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSubmit)
            .padding(.horizontal)

            Button("auth.forgot_password.button") {
                viewModel.didTapForgotPassword()
            }
            .font(.footnote)

            Spacer()
        }
        .navigationTitle("auth.sign_in.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
