//
//  IVSPreviewViewWrapper.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 06/09/2021.
//  

import AmazonIVSPlayer
import SwiftUI

struct IVSPlayerViewWrapper: UIViewRepresentable {
    let playerView: IVSPlayerView?

    func makeUIView(context: Context) -> IVSPlayerView {
        guard let view = playerView else {
            print("ℹ No actual player view passed to wrapper. Returning new IVSPlayerView")
            return IVSPlayerView()
        }
        return view
    }

    func updateUIView(_ uiView: IVSPlayerView, context: Context) {}
}
