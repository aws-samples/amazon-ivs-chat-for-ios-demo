//
//  CustomTextField.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 13/09/2021.
//  

import SwiftUI

struct CustomTextField: UIViewRepresentable {
    @Binding public var text: String
    let onCommit: () -> Void

    public init(text: Binding<String>, onCommit: @escaping () -> Void) {
        self.onCommit = onCommit
        self._text = text
    }

    public func makeUIView(context: Context) -> UITextField {
        let view = UITextField()
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 15)
        view.addTarget(context.coordinator, action: #selector(Coordinator.textViewDidChange), for: .editingChanged)
        view.delegate = context.coordinator
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator($text, onCommit: onCommit)
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var onCommit: () -> Void

        init(_ text: Binding<String>, onCommit: @escaping () -> Void) {
            self.text = text
            self.onCommit = onCommit
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onCommit()
            return false
        }

        @objc public func textViewDidChange(_ textField: UITextField) {
            self.text.wrappedValue = textField.text ?? ""
        }
    }
}
