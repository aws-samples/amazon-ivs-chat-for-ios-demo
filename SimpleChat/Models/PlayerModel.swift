//
//  PlayerModel.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 06/09/2021.
//  

import AmazonIVSPlayer

class PlayerModel: ObservableObject {
    let playerDelegate: IVSPlayer.Delegate?

    @Published var playerView: IVSPlayerView?
    @Published var player: IVSPlayer?
    @Published var url: String {
        didSet {
            if oldValue != url, let _ = player {
                play(url)
            }
        }
    }

    init() {
        self.url = ""
        self.playerDelegate = PlayerDelegate()
        self.playerView = IVSPlayerView(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: UIScreen.main.bounds.width,
                                                      height: UIScreen.main.bounds.height))

        if let delegate = playerDelegate as? PlayerDelegate {
            delegate.playerModel = self
        }
    }

    func play(_ stringUrl: String) {
        url = stringUrl
        player = IVSPlayer()

        player?.delegate = playerDelegate
        player?.muted = Constants.isMuted

        playerView?.player = player
        playerView?.videoGravity = .resizeAspectFill

        if let url = URL(string: stringUrl) {
            print("ℹ loading playback url \(stringUrl)")
            player?.load(url)
        }
    }
}

class PlayerDelegate: UIViewController, IVSPlayer.Delegate {
    var playerModel: PlayerModel?

    func player(_ player: IVSPlayer, didChangeState state: IVSPlayer.State) {
        switch state {
        case .idle:
            print("ℹ IVSPlayer state IDLE")
        case .ready:
            print("ℹ IVSPlayer state READY")
            player.play()
        case .buffering:
            print("ℹ IVSPlayer state BUFFERING")
        case .playing:
            print("ℹ IVSPlayer state PLAYING")
        case .ended:
            print("ℹ IVSPlayer state ENDED")
        @unknown default:
            print("❌ Unknown IVSPlayer state '\(state)'")
        }
    }
}
