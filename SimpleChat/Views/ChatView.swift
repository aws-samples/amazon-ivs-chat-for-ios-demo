//
//  MessagesView.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 07/09/2021.
//  

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var selectedMessage: Message?

    var body: some View {
        GeometryReader { geometry in
            if viewModel.useBulletChatMode {
                BulletChatView()
                    .frame(minHeight: geometry.size.height, maxHeight: geometry.size.height)
                    .frame(maxWidth: UIScreen.main.bounds.width)
            } else {
                SimpleChatView(selectedMessage: $selectedMessage)
            }
        }
    }
}
