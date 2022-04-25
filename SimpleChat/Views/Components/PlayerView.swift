//
//  VideoPreviewView.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 06/09/2021.
//  

import SwiftUI

struct PlayerView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        IVSPlayerViewWrapper(playerView: viewModel.playerModel.playerView)
            .background(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 1))
    }
}
