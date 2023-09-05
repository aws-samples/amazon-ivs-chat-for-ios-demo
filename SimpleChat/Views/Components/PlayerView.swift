//
//  VideoPreviewView.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 06/09/2021.
//  

import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        IVSPlayerViewWrapper(playerModel: viewModel.playerModel)
            .background(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 1))
    }
}
