//
//  User.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 06/09/2021.
//  

import Foundation

struct User: Codable {
    var id: String
    var username: String
    var avatarUrl: String
    var isModerator: Bool

    init(id: String = UUID().uuidString, username: String, avatarUrl: String = Constants.userAvatarUrls[0]) {
        self.id = id
        self.username = username
        self.avatarUrl = avatarUrl
        self.isModerator = true
    }
}
