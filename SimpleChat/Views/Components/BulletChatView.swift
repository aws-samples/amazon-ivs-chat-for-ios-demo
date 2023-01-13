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
    @State var availableRows: [Int] = []

    private let rowCount: Int = 7
    private let totalHeight = UIScreen.main.bounds.height - 150
    private let totalWidth = UIScreen.main.bounds.width
    private var rowHeight: CGFloat {
        totalHeight / CGFloat(rowCount)
    }

    var body: some View {
        ZStack {
            ForEach(bulletMessages) { bulletMessage in
                GeometryReader { geometry in
                    BulletMessageView(
                        bulletMessages: $bulletMessages,
                        bulletMessage: bulletMessage,
                        animationTime: getRandomAnimationTime()
                    )
                }
            }
        }
        .frame(height: totalHeight)
        .onChange(of: viewModel.messages) { messages in
            if let message = messages.last as? Message {
                let newBulletMessage = BulletMessage(message: message, position: getPositionForNextBulletMessage())
                bulletMessages.append(newBulletMessage)
            }
        }
    }

    private func getPositionForNextBulletMessage() -> CGPoint {
        if availableRows.isEmpty {
            for row in 1...rowCount {
                availableRows.append(row)
            }
        }
        let targetRow = availableRows.randomElement() ?? 0
        return CGPoint(x: totalWidth, y: CGFloat(targetRow) * rowHeight)
    }

    private func getRandomAnimationTime() -> Double {
        var time: Double = 6
        time += Double.random(in: 0.5...1.5)
        return time
    }
}

struct BulletMessageView: View {
    @Binding var bulletMessages: [BulletMessage]
    var bulletMessage: BulletMessage?
    var animationTime: Double = 0
    @State private var xOffset: CGFloat = 0

    init(bulletMessages: Binding<[BulletMessage]>, bulletMessage: BulletMessage, animationTime: Double) {
        self._bulletMessages = bulletMessages
        self.bulletMessage = bulletMessage
        self.animationTime = animationTime
        self.xOffset = UIScreen.main.bounds.width
    }

    var body: some View {
        GeometryReader { proxy in
            HStack {
                switch bulletMessage?.message.attributes?.type ?? .message {
                    case .message:
                        Text(bulletMessage?.message.content ?? "")
                            .font(Constants.fAppLarge)
                            .shadow(color: .black.opacity(0.75), radius: 4, x: 0, y: 2)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .lineLimit(1)
                            .fixedSize()
                    case .sticker:
                        if let stickerSrc = bulletMessage?.message.attributes?.stickerSrc {
                            RemoteImageView(imageURL: stickerSrc)
                                .frame(width: 150, height: 150)
                                .transition(.identity)
                        }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .position(x: (bulletMessage?.position.x ?? 0) + proxy.size.width / 2, y: bulletMessage?.position.y ?? 0)
            .onAppear {
                withAnimation {
                    xOffset = -((bulletMessage?.position.x ?? 0) + proxy.size.width) * 2
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
                    if let index = bulletMessages.firstIndex(where: { $0.id.uuidString == bulletMessage?.id.uuidString }) {
                        bulletMessages.remove(at: index)
                    }
                }
            }
            .animation(.linear(duration: animationTime), value: xOffset)
            .offset(x: xOffset + proxy.size.width)
        }
    }
}
