//
//  StickersView.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 09/09/2021.
//  

import SwiftUI

struct StickersView: View {
    @StateObject var viewModel: ViewModel

    private let stickerSize: CGFloat = 100

    var body: some View {
        VStack {
            Text("Stickers")
                .foregroundColor(.white)
                .font(Constants.fAppBold)
                .padding(.top, 20)
                .padding(.bottom, 0)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.fixed(stickerSize)), GridItem(.fixed(stickerSize))], alignment: .center, spacing: 8) {
                    ForEach(Constants.stickerUrls, id: \.self) { url in
                        RemoteImageView(imageURL: url)
                            .frame(width: stickerSize, height: stickerSize)
                            .onTapGesture {
                                guard let user = viewModel.user else { return }
                                viewModel.websocket.sendMessage(url, type: .sticker, avatarUrl: user.avatarUrl)
                            }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .background(Constants.background)
        .frame(maxWidth: .infinity)
        .transition(.move(edge: .bottom))
    }
}
