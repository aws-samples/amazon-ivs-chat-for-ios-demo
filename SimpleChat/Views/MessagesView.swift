//
//  MessagesView.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 07/09/2021.
//  

import SwiftUI

struct MessagesView: View {
    @StateObject var websocket: WebSocketModel
    @Binding var selectedMessage: Message?

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(alignment: .leading) {
                        ForEach(websocket.messages, id: \.self) { messageObject in
                            if let message = messageObject as? Message {
                                MessageView(
                                    websocket: websocket,
                                    message: message,
                                    selectedMessage: $selectedMessage)
                            } else if let success = messageObject as? SuccessMessage {
                                SystemMessageView(text: success.text, color: Constants.appGreen)
                            } else if let error = messageObject as? ErrorMessage {
                                SystemMessageView(text: error.text, details: error.details, color: Constants.appRed)
                            }
                        }
                    }
                    .rotationEffect(.radians(.pi))
                    .scaleEffect(x: -1, y: 1, anchor: .center)
                    .frame(minHeight: UIScreen.main.bounds.height - 150, alignment: .top)
                    .animation(.easeInOut(duration: 0.25))
                }
                .padding(.horizontal, 16)
                .rotationEffect(.radians(.pi))
                .scaleEffect(x: -1, y: 1, anchor: .center)
                .onChange(of: websocket.messages, perform: { _ in
                    guard let lastMessage = websocket.messages.last as? Message else { return }
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                })
            }
        }
    }
}

struct MessageView: View {
    @StateObject var websocket: WebSocketModel
    @State var message: Message
    @Binding var selectedMessage: Message?

    @State private var offsetY: CGFloat = 50
    @State private var opacity: Double = 0

    var body: some View {
        VStack(alignment: .leading) {
            MessagePreviewView(message: message)
        }
        .offset(y: offsetY)
        .opacity(opacity)
        .onAppear {
            withAnimation {
                offsetY = 0
                opacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.messagesTimeout) {
                offsetY = -50
                opacity = 0
            }
        }
        .onLongPressGesture {
            guard let user = websocket.viewModel?.user, user.isModerator else { return }
            withAnimation {
                selectedMessage = message
            }
        }
    }
}

struct MessagePreviewView: View {
    @State var message: Message
    @State private var stickerScale: CGFloat = 0

    var body: some View {
        HStack(alignment: message.attributes?.type ?? .message == .sticker ? .center : .top) {
            RemoteImageView(imageURL: message.sender.attributes.avatar)
                .frame(width: 32, height: 32)
                .cornerRadius(42)
            if message.attributes?.type ?? .message == .sticker {
                Text(message.sender.attributes.username)
                    .frame(height: 32)
                    .foregroundColor(.black)
                    .font(Constants.fAppBold)
            }

            switch message.attributes?.type ?? .message {
                case .message:
                    Text("\(Text(message.sender.attributes.username).font(Constants.fAppBold)) \(message.content)")
                        .font(Constants.fAppRegular)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                case .sticker:
                    if let stickerSrc = message.attributes?.stickerSrc {
                        RemoteImageView(imageURL: stickerSrc)
                            .frame(width: 150, height: 150)
                            .scaleEffect(stickerScale)
                            .transition(.identity)
                            .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0).delay(0.25), value: stickerScale)
                            .onAppear {
                                withAnimation() {
                                    stickerScale = 1
                                }
                            }
                    }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(message.attributes?.type ?? .message == .sticker ? Constants.stickerBackground : Constants.background.opacity(0.7))
        .cornerRadius(24)
    }
}

struct SystemMessageView: View {
    var text: String
    var details: String = ""
    var color: Color

    @State private var offsetY: CGFloat = 50
    @State private var opacity: Double = 0

    var body: some View {
        HStack() {
            Text("\(Text(text).font(Constants.fAppBold)) \(details)")
                .font(Constants.fAppRegular)
                .foregroundColor(.white)
                .padding(.vertical, 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(color)
        .cornerRadius(24)
        .offset(y: offsetY)
        .opacity(opacity)
        .onAppear {
            withAnimation {
                offsetY = 0
                opacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.messagesTimeout) {
                offsetY = -50
                opacity = 0
            }
        }
    }
}
