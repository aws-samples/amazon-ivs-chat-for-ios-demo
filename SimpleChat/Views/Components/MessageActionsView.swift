//
//  MessageActionsView.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 10/03/2022.
//

import SwiftUI

struct MessageActionsView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var selectedMessage: Message?

    var body: some View {
        ZStack(alignment: .bottom, content: {
            VisualEffectView(effect: UIBlurEffect(style: .dark))

            VStack {
                if let message = selectedMessage {
                    MessagePreviewView(message: message)
                        .padding(.horizontal, 16)
                }

                VStack(spacing: 15) {
                    if let message = selectedMessage {
                        Button(action: {
                            viewModel.delete(message: message.id)
                            withAnimation { selectedMessage = nil }
                        }) {
                            Text("Delete message")
                                .modifier(ActionButton(backgroundColor: Constants.appRed))
                        }

                        Button(action: {
                            viewModel.kick(user: message.sender.id)
                            withAnimation { selectedMessage = nil }
                        }) {
                            Text("Kick user")
                                .modifier(ActionButton(backgroundColor: Constants.appRed))
                        }
                    }
                    Button(action: {
                        withAnimation { selectedMessage = nil }
                    }) {
                        Text("Cancel")
                            .modifier(ActionButton())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
                .background(Color.black)
                .cornerRadius(20)
                .padding(.bottom, 40)
                .padding(.horizontal, 16)
            }
        })
            .animation(.easeOut(duration: 0.3), value: selectedMessage)
    }
}
