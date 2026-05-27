//
//  PasswordTextField.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 6.04.26.
//

import SwiftUI
import UIKit

struct PasswordTextField: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    var onSubmit: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmit: onSubmit)
    }

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.textContentType = .password
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.keyboardType = .default
        field.returnKeyType = .send
        field.font = .preferredFont(forTextStyle: .body)
        field.delegate = context.coordinator
        field.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        return field
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.placeholder != placeholder {
            uiView.placeholder = placeholder
        }
        if uiView.isSecureTextEntry != isSecure {
            let saved = uiView.text ?? ""
            uiView.isSecureTextEntry = isSecure
            uiView.text = ""
            uiView.insertText(saved)
        } else if uiView.text != text {
            uiView.text = text
        }
        context.coordinator.onSubmit = onSubmit
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        var onSubmit: (() -> Void)?

        init(text: Binding<String>, onSubmit: (() -> Void)?) {
            _text = text
            self.onSubmit = onSubmit
        }

        @objc func textChanged(_ sender: UITextField) {
            text = sender.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onSubmit?()
            return false
        }
    }
}
