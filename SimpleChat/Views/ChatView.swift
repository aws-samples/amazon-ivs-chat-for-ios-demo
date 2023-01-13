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
        if viewModel.useBulletChatMode {
            BulletChatView()
        } else {
            SimpleChatView(selectedMessage: $selectedMessage)
        }
    }
}
