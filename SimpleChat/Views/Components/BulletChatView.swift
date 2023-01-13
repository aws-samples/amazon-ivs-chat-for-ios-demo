//
//  BulletChatView.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 12/01/2023.
//

import SwiftUI

struct BulletMessage: Identifiable {
    var id: UUID
    var message: Message
    var position: CGPoint

    init(message: Message, position: CGPoint) {
        self.id = UUID()
        self.message = message
        self.position = position
    }
}

struct BulletChatView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var bulletMessages: [BulletMessage] = []

    private let rowCount: CGFloat = 7
    private let totalHeight = UIScreen.main.bounds.height - 150
    private let totalWidth = UIScreen.main.bounds.width
    private var rowHeight: CGFloat {
        totalHeight / rowCount
    }

    var body: some View {
        ZStack {
            ForEach(bulletMessages) { bulletMessage in
                GeometryReader { geometry in
                    BulletMessageView(
                        message: bulletMessage.message,
                        startPosition: bulletMessage.position,
                        size: geometry.size
                    )
                }
            }
        }
        .frame(height: totalHeight)
        .onChange(of: viewModel.messages) { messages in
            if let message = messages.last as? Message {
                let newBulletMessage = BulletMessage(message: message, position: GetPositionForNextBulletMessage())
                bulletMessages.append(newBulletMessage)
            }
        }
    }

    private func GetPositionForNextBulletMessage() -> CGPoint {
        var targetRow: CGFloat = 1

        return CGPoint(x: totalWidth, y: targetRow * rowHeight)
    }
}

struct BulletMessageView: View {
    var message: Message?
    var startPosition: CGPoint = CGPoint.zero
    var size: CGSize = CGSize.zero
    @State private var xOffset: CGFloat = 0

    init(message: Message, startPosition: CGPoint, size: CGSize) {
        self.message = message
        self.startPosition = startPosition
        self.size = size
        self.xOffset = UIScreen.main.bounds.width + size.width
    }

    var body: some View {
        HStack {
            switch message?.attributes?.type ?? .message {
                case .message:
                    Text(message?.content ?? "")
                        .font(Constants.fAppLarge)
                        .shadow(color: .black.opacity(0.75), radius: 4, x: 0, y: 2)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                case .sticker:
                    if let stickerSrc = message?.attributes?.stickerSrc {
                        RemoteImageView(imageURL: stickerSrc)
                            .frame(width: 150, height: 150)
                            .transition(.identity)
                    }
            }
        }
        .frame(width: size.width, height: size.height)
        .position(x: startPosition.x + size.width / 2, y: startPosition.y)
        .onAppear {
            withAnimation {
                xOffset = -startPosition.x * 2
            }
        }
        .animation(.linear(duration: 5), value: xOffset)
        .offset(x: xOffset)
    }
}
