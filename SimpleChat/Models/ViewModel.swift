//
//  ViewModel.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 06/09/2021.
//  

import AmazonIVSPlayer

class ViewModel: ObservableObject {
    let playerModel = PlayerModel()
    var websocket = WebSocketModel()

    @Published var isAuthorised: Bool = false
    @Published var user: User? {
        didSet {
            websocket.authenticate()
        }
    }
    @Published var customPlaybackUrl: String {
        didSet {
            UserDefaults.standard.setValue(customPlaybackUrl, forKey: Constants.kLiveStreamUrl)
            playerModel.url = useCustomStreamUrl ? customPlaybackUrl : Constants.playbackUrl
        }
    }
    @Published var useCustomStreamUrl: Bool {
        didSet {
            UserDefaults.standard.setValue(useCustomStreamUrl, forKey: Constants.kUseCustomLiveStreamUrl)
        }
    }

    init() {
        let useCustom = UserDefaults.standard.bool(forKey: Constants.kUseCustomLiveStreamUrl)
        self.useCustomStreamUrl = useCustom
        self.customPlaybackUrl = UserDefaults.standard.string(forKey: Constants.kLiveStreamUrl) ?? ""
        websocket.viewModel = self
    }

    func startPlayback() {
        playerModel.play(useCustomStreamUrl ? customPlaybackUrl : Constants.playbackUrl)
    }
}
