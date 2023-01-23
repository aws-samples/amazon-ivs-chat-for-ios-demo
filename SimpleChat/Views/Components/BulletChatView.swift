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
    var relativeHeightPosition: CGFloat

    init(message: Message, relativeHeightPosition: CGFloat) {
        self.id = UUID()
        self.message = message
        self.relativeHeightPosition = relativeHeightPosition
    }
}

struct BulletChatView: View {
    @EnvironmentObject var viewModel: ViewModel
    @ObservedObject private var keyboard = KeyboardResponder()

    @State var bulletMessages: [BulletMessage] = []
    @State var availableRows: [Int] = []

    private let rowCount: Int = 7

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
                let newBulletMessage = BulletMessage(message: message,
                                                     relativeHeightPosition: getHeightPositionForBulletMessage())
                bulletMessages.append(newBulletMessage)
            }
        }
    }

    private func getHeightPositionForBulletMessage() -> CGFloat {
        if availableRows.isEmpty {
            for row in 1...rowCount {
                availableRows.append(row)
            }
        }
        let targetRow = availableRows.randomElement() ?? 0
        if let index = availableRows.firstIndex(of: targetRow) {
            availableRows.remove(at: index)
        }
        return 1 / CGFloat(rowCount) * CGFloat(targetRow)
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
    @State private var yPosition: CGFloat = 0

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
                                .onAppear {
                                    contentWidth = 120
                                }
                        }
                }
            }
            .onAppear {
                yPosition = (bulletMessage?.relativeHeightPosition ?? 0) * geometry.size.height
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    xOffset = -geometry.size.width - contentWidth

                    DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
                        if let index = bulletMessages.firstIndex(where: { $0.id.uuidString == bulletMessage?.id.uuidString }) {
                            bulletMessages.remove(at: index)
                        }
                    }
                }
            }
            .position(x: geometry.size.width + contentWidth / 2, y: yPosition)
            .animation(.linear(duration: animationTime), value: xOffset)
            .offset(x: xOffset)
            .onChange(of: geometry.size.height) { newValue in
                yPosition = (bulletMessage?.relativeHeightPosition ?? 0) * geometry.size.height
            }
        }
    }
}
