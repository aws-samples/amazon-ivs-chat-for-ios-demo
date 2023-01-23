//
//  MessagesInputView.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 09/09/2021.
//  

import SwiftUI

struct BottomBarView: View {
    @StateObject var viewModel: ViewModel
    @ObservedObject var keyboard: KeyboardResponder
    @Binding var isLoginPresent: Bool
    @Binding var isStickersPresent: Bool

    @State private var messageText: String = ""

    private func send() {
        if let user = viewModel.user, !messageText.isEmpty {
            viewModel.sendMessage(messageText, type: .message, avatarUrl: user.avatarUrl)
            messageText = ""
        }
    }

    var body: some View {
        if viewModel.isAuthorised, let user = viewModel.user {
            HStack {
                HStack {
                    RemoteImageView(imageURL: user.avatarUrl)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        .padding(.leading, 16)
                    CustomTextField(text: $messageText, onCommit: { send() })
                        .placeholder(when: messageText.isEmpty) {
                            Text("Send a message")
                                .font(Constants.fAppRegular)
                                .foregroundColor(Color.gray)
                        }
                    Image(systemName: "doc.fill")
                        .foregroundColor(isStickersPresent ? Constants.buttonPrimary : Constants.iconInactive)
                        .padding()
                        .onTapGesture {
                            UIApplication.shared
                                .sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            withAnimation {
                                isStickersPresent.toggle()
                            }
                        }
                }
                .frame(height: 48)
                .background(Constants.background)
                .cornerRadius(42)

                Image(systemName: "paperplane.fill")
                    .frame(width: 48, height: 48)
                    .font(.system(size: 20))
                    .background(Constants.background)
                    .foregroundColor(messageText.isEmpty ? Constants.iconInactive : Constants.iconActive)
                    .clipShape(Circle())
                    .rotationEffect(.degrees(43))
                    .onTapGesture {
                        send()
                    }
            }
            .padding(.horizontal, 16)
        } else if keyboard.currentHeight == 0 {
            Button(action: {
                withAnimation {
                    isLoginPresent.toggle()
                }
            }, label: {
                Text("Tap to chat")
                    .foregroundColor(Constants.background)
                    .font(Constants.fAppBold)
                    .frame(maxWidth: UIScreen.main.bounds.width)
                    .frame(height: 48)
                    .background(Constants.buttonPrimary)
                    .cornerRadius(42)
                    .padding(.horizontal, 16)
            })
        }
    }
}
