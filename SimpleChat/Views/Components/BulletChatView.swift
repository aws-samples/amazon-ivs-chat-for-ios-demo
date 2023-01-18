//
//  BulletChatView.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 12/01/2023.
//

import SwiftUI
import Combine

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
    @ObservedObject private var keyboard = KeyboardResponder()

    @State var bulletMessages: [BulletMessage] = []
    @State var availableRows: [Int] = []

    private let rowCount: Int = 7
    private let totalWidth = UIScreen.main.bounds.width
    private var rowHeight: CGFloat {
        (UIScreen.main.bounds.height - 200) / CGFloat(rowCount)
    }

    var body: some View {
        ZStack {
            if bulletMessages.isEmpty {
                Text("").frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ForEach(bulletMessages) { bulletMessage in
                    BulletMessageView(
                        bulletMessages: $bulletMessages,
                        bulletMessage: bulletMessage,
                        animationTime: getAnimationTime()
                    )
                }
            }
        }
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
        if let index = availableRows.firstIndex(of: targetRow) {
            availableRows.remove(at: index)
        }
        return CGPoint(x: totalWidth, y: CGFloat(targetRow) * rowHeight)
    }

    private func getAnimationTime() -> Double {
        let baseTime: Double = 4
        return baseTime + Double.random(in: 0.5...1.5)
    }
}

struct BulletMessageView: View {
    @Binding var bulletMessages: [BulletMessage]
    var bulletMessage: BulletMessage?
    var animationTime: Double = 0
    @State private var xOffset: CGFloat = 0
    @State private var contentWidth: CGFloat = 0

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(bulletMessages: Binding<[BulletMessage]>, bulletMessage: BulletMessage, animationTime: Double) {
        self._bulletMessages = bulletMessages
        self.bulletMessage = bulletMessage
        self.animationTime = animationTime
        self.xOffset = UIScreen.main.bounds.width
    }

    var body: some View {
        GeometryReader { geometry in
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
                            .onAppear {
                                let label = UILabel(frame: CGRectZero)
                                label.text = bulletMessage?.message.content ?? ""
                                label.font = UIFont.systemFont(ofSize: 24)
                                contentWidth = label.intrinsicContentSize.width
                            }
                    case .sticker:
                        if let stickerSrc = bulletMessage?.message.attributes?.stickerSrc {
                            RemoteImageView(imageURL: stickerSrc)
                                .frame(width: 150, height: 150)
                                .transition(.identity)
                                .onAppear {
                                    contentWidth = 120
                                }
                        }
                }
            }
            .position(x: geometry.size.width + contentWidth / 2, y: bulletMessage?.position.y ?? 0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    xOffset = -geometry.size.width - contentWidth

                    DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
                        if let index = bulletMessages.firstIndex(where: { $0.id.uuidString == bulletMessage?.id.uuidString }) {
                            bulletMessages.remove(at: index)
                        }
                    }
                }
            }
            .animation(.linear(duration: animationTime), value: xOffset)
            .offset(x: xOffset)
        }
    }
}
