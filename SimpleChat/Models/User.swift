//
//  User.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 06/09/2021.
//  

import Foundation

struct User: Equatable {
    var id: String
    var username: String
    var avatarUrl: String
    var isModerator: Bool

    init(username: String, avatarUrl: String = Constants.userAvatarUrls[0]) {
        self.id = UUID().uuidString
        self.username = username
        self.avatarUrl = avatarUrl
        self.isModerator = true
    }
}
