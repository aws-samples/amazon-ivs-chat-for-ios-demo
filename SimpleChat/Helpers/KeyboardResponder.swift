//
//  KeyboardResponder.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 09/09/2021.
//  

import SwiftUI

final class KeyboardResponder: ObservableObject {
    private let notificationCenter: NotificationCenter = .default
    @Published private(set) var currentHeight: CGFloat = 0

    init() {
        notificationCenter.addObserver(self,
                                       selector: #selector(keyBoardWillShow(notification:)),
                                       name: UIResponder.keyboardWillShowNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillChangeFrame(notification:)),
                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil)

    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = min(keyboardSize.height, 268)
        }
    }

    @objc func keyboardWillChangeFrame(notification: Notification) {
        currentHeight = 0
    }
}
