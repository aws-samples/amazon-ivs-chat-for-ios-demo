//
//  StickersView.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 09/09/2021.
//  

import SwiftUI

struct StickersView: View {
    @EnvironmentObject var viewModel: ViewModel

    private let stickerSize: CGFloat = 100

    var body: some View {
        VStack {
            Text("Stickers")
                .foregroundColor(.white)
                .font(Constants.fAppBold)
                .padding(.top, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.fixed(stickerSize)), GridItem(.fixed(stickerSize))], alignment: .center, spacing: 8) {
                    ForEach(Constants.stickerUrls, id: \.self) { url in
                        RemoteImageView(imageURL: url)
                            .frame(width: stickerSize, height: stickerSize)
                            .onTapGesture {
                                guard let user = viewModel.user else { return }
                                viewModel.sendMessage(url, type: .sticker, avatarUrl: user.avatarUrl)
                            }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .background(Constants.background)
        .frame(maxWidth: UIScreen.main.bounds.width)
        .transition(.move(edge: .bottom))
    }
}
