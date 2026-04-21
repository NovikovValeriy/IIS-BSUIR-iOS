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
        static let outerSpacing: CGFloat = 32
        static let fieldSpacing: CGFloat = 12
        static let buttonHeight: CGFloat = 50
        static let fieldHeight: CGFloat = 54
        static let fieldCornerRadius: CGFloat = 12
        static let fieldHorizontalPadding: CGFloat = 14
        static let eyeButtonWidth: CGFloat = 44
        static let keyboardOffset: CGFloat = 120
    }
    enum Icons {
        static let showPassword = "eye"
        static let hidePassword = "eye.slash"
    }
}

private enum LoginField {
    case username, password
}

struct LoginView: View {
    @State private var viewModel: LoginViewModel = Container.shared.loginViewModel()
    @State private var isPasswordVisible: Bool = false
    @State private var keyboardVisible: Bool = false
    @FocusState private var focusedField: LoginField?

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
                    .submitLabel(.next)
                    .focused($focusedField, equals: .username)
                    .onSubmit { focusedField = .password }
                    .padding(.horizontal, Constants.Layout.fieldHorizontalPadding)
                    .frame(height: Constants.Layout.fieldHeight)
                    .background(
                        Color(.secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: Constants.Layout.fieldCornerRadius)
                    )

                passwordField
            }
            .padding(.horizontal)

            Button {
                focusedField = nil
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

            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture { focusedField = nil }
        .simultaneousGesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    if value.translation.height > 0 { focusedField = nil }
                }
        )
        .offset(y: keyboardVisible ? -Constants.Layout.keyboardOffset : 0)
        .animation(.easeInOut(duration: 0.25), value: keyboardVisible)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            keyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardVisible = false
        }
        .ignoresSafeArea(.keyboard)
        .navigationTitle("auth.sign_in.title")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var passwordField: some View {
        ZStack(alignment: .trailing) {
            PasswordTextField(
                placeholder: String(localized: "auth.password.placeholder"),
                text: $viewModel.password,
                isSecure: !isPasswordVisible,
                onSubmit: {
                    focusedField = nil
                    Task { await viewModel.login() }
                }
            )
            .focused($focusedField, equals: .password)
            .padding(.horizontal, Constants.Layout.fieldHorizontalPadding)
            .padding(.trailing, Constants.Layout.eyeButtonWidth)
            .frame(height: Constants.Layout.fieldHeight)
            .background(
                Color(.secondarySystemBackground),
                in: RoundedRectangle(cornerRadius: Constants.Layout.fieldCornerRadius)
            )

            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? Constants.Icons.hidePassword : Constants.Icons.showPassword)
                    .foregroundStyle(.secondary)
                    .frame(width: Constants.Layout.eyeButtonWidth, height: Constants.Layout.fieldHeight)
            }
        }
    }
}
