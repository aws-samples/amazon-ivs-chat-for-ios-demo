//
//  Message.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 07/09/2021.
//  

import Foundation

enum MessageObjectType {
    case message, error, success
}

enum MessageType: String {
    case message = "MESSAGE", sticker = "STICKER"
}

struct Message: Identifiable, Equatable, Hashable {
    struct Sender {
        struct Attributes: Decodable {
            let avatar: String
            let username: String
        }

        let userId: String
        let attributes: Attributes
    }

    struct Attributes {
        let type: MessageType
        let stickerSrc: String

        init(type: MessageType, stickerSrc: String) {
            self.type = type
            self.stickerSrc = stickerSrc
        }
    }

    var id: String
    let objectType: MessageObjectType
    let type: MessageType
    let requestId: String
    let content: String
    let attributes: Attributes?
    let sendTime: String
    let sender: User

    init(id: String,
         objectType: MessageObjectType,
         type: MessageType,
         requestId: String,
         content: String,
         attributes: Attributes?,
         sendTime: String,
         sender: User) {
        self.id = id
        self.objectType = objectType
        self.type = type
        self.requestId = requestId
        self.content = content
        self.attributes = attributes
        self.sendTime = sendTime
        self.sender = sender
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ErrorMessage: Hashable {
    let id: String
    let objectType: MessageObjectType
    let text: String
    let details: String

    init(text: String, details: String) {
        self.id = UUID().uuidString
        self.objectType = .error
        self.text = text
        self.details = details
    }

    static func == (lhs: ErrorMessage, rhs: ErrorMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SuccessMessage: Hashable {
    let id: String
    let objectType: MessageObjectType
    let text: String

    init(text: String) {
        self.id = UUID().uuidString
        self.objectType = .success
        self.text = text
    }

    static func == (lhs: SuccessMessage, rhs: SuccessMessage) -> Bool {
        return lhs.id == rhs.id
    }
}
