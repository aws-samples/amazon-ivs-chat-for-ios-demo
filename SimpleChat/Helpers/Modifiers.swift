//
//  Modifiers.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 16/09/2021.
//  

import SwiftUI

struct ClearButton: ViewModifier {
    @Binding var text: String

    public func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
            Image(systemName: "multiply.circle.fill")
                .foregroundColor(.gray)
                .opacity(text == "" ? 0 : 1)
                .onTapGesture {
                    self.text = ""
                }
        }
    }
}

struct ActionButton: ViewModifier {
    var backgroundColor: Color = .clear

    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundColor(.white)
            .font(Constants.fAppBold)
            .background(backgroundColor)
            .cornerRadius(42)
    }
}
