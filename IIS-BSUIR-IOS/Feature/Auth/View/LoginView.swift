//
//  LoginView.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import Factory

private enum Constants {
    enum Layout {
        static let outerSpacing: CGFloat = 24
        static let fieldSpacing: CGFloat = 16
        static let buttonHeight: CGFloat = 44
    }
}

struct LoginView: View {
    @State private var viewModel: LoginViewModel = Container.shared.loginViewModel()

    var body: some View {
        VStack(spacing: Constants.Layout.outerSpacing) {
            Spacer()

            Text("auth.title")
                .font(.largeTitle.bold())

            VStack(spacing: Constants.Layout.fieldSpacing) {
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
                .frame(height: Constants.Layout.buttonHeight)
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
