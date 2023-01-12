//
//  Constants.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 06/09/2021.
//  

import SwiftUI

enum Constants {
    // Replace this with your own Amazon IVS Playback URL
    static let playbackUrl = "https://760b256a3da8.us-east-1.playback.live-video.net/api/video/v1/us-east-1.049054135175.channel.6tM2Z9kY16nH.m3u8"

    // Player starts muted or not
    static let isMuted: Bool = true

    // Authorization endpoint
    // Endpoint for the Amazon IVS Chat Demo Backend, which is available on github: https://github.com/aws-samples/amazon-ivs-chat-web-demo/tree/main/serverless
    static let apiUrl = ""

    // AWS Region
    // The aws region for the chat room itself: 'arn:aws:ivschat:<AWS_REGION>:012345678910:room/ABCDEFGHIJK'
    static let awsRegion = ""

    // Chat room id
    static let chatRoomId = ""

    // Timeout after which received messages disappear
    static let messagesTimeout = 20.0

    // Avatar urls for chat users
    static let userAvatarUrls: [String] = [
        "https://d39ii5l128t5ul.cloudfront.net/assets/animals_square/bear.png",
        "https://d39ii5l128t5ul.cloudfront.net/assets/animals_square/bird.png",
        "https://d39ii5l128t5ul.cloudfront.net/assets/animals_square/bird2.png",
        "https://d39ii5l128t5ul.cloudfront.net/assets/animals_square/giraffe.png",
        "https://d39ii5l128t5ul.cloudfront.net/assets/animals_square/hedgehog.png",
        "https://d39ii5l128t5ul.cloudfront.net/assets/animals_square/hippo.png"
    ]

    // Sticker urls
    static let stickerUrls: [String] = [
        "https://d39ii5l128t5ul.cloudfront.net/assets/chat/v1/sticker-1.png",
        "https://d39ii5l128t5ul.cloudfront.net/assets/chat/v1/sticker-2.png",
        "https://d39ii5l128t5ul.cloudfront.net/assets/chat/v1/sticker-3.png",
        "https://d39ii5l128t5ul.cloudfront.net/assets/chat/v1/sticker-4.png",
        "https://d39ii5l128t5ul.cloudfront.net/assets/chat/v1/sticker-5.png",
        "https://d39ii5l128t5ul.cloudfront.net/assets/chat/v1/sticker-6.png",
        "https://d39ii5l128t5ul.cloudfront.net/assets/chat/v1/sticker-7.png",
        "https://d39ii5l128t5ul.cloudfront.net/assets/chat/v1/sticker-8.png",
        "https://d39ii5l128t5ul.cloudfront.net/assets/chat/v1/sticker-9.png",
        "https://d39ii5l128t5ul.cloudfront.net/assets/chat/v1/sticker-10.png",
        "https://d39ii5l128t5ul.cloudfront.net/assets/chat/v1/sticker-11.png"
    ]

    // App colors
    static let buttonPrimary = Color(.sRGB, red: 1, green: 0.89, blue: 0.29, opacity: 1)
    static let buttonDisabled = Color(.sRGB, red: 0.26, green: 0.26, blue: 0.26, opacity: 1)
    static let iconInactive = Color(.sRGB, red: 0.39, green: 0.39, blue: 0.39, opacity: 1)
    static let iconActive = Color(.sRGB, red: 0.59, green: 0.59, blue: 0.59, opacity: 1)
    static let stickerBackground = Color(.sRGB, red: 1, green: 0.91, blue: 0.50, opacity: 1)
    static let background = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 1)
    static let backgroundSettings = Color(.sRGB, red: 0.12, green: 0.12, blue: 0.12, opacity: 1)
    static let backgroundInput = Color(.sRGB, red: 0.09, green: 0.09, blue: 0.09, opacity: 1)
    static let appRed = Color(.sRGB, red: 0.8, green: 0.26, blue: 0.18, opacity: 1)
    static let appGreen = Color(.sRGB, red: 0.20, green: 0.55, blue: 0.26)

    // App fonts
    static let fAppSmall = Font.system(size: 12)
    static let fAppRegular = Font.system(size: 15)
    static let fAppBold = Font.system(size: 15, weight: .bold)
    static let fAppTitleBold = Font.system(size: 17, weight: .bold)
    static let fAppTitleRegular = Font.system(size: 17)

    // Persistence keys
    static let kUseCustomLiveStreamUrl = "use_custom_live_stream_url"
    static let kUseBulletChatMode = "use_bullet_chat_mode"
    static let kLiveStreamUrl = "live_stream_url"
}
