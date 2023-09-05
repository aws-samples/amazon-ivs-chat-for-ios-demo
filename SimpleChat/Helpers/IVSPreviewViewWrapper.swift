//
//  IVSPreviewViewWrapper.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 06/09/2021.
//  

import AmazonIVSPlayer
import SwiftUI

struct IVSPlayerViewWrapper: UIViewRepresentable {
    let playerModel: PlayerModel

    func makeUIView(context: Context) -> IVSPlayerView {
        let playerView = IVSPlayerView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        playerView.videoGravity = .resizeAspectFill
        return playerView
    }

    func updateUIView(_ uiView: IVSPlayerView, context: Context) {
        uiView.player = playerModel.player
    }
}
