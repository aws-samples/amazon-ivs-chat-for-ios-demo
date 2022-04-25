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

struct Message: Decodable, Identifiable, Equatable, Hashable {
    struct Sender: Decodable {
        struct Attributes: Decodable {
            let avatar: String
            let username: String
        }

        let userId: String
        let attributes: Attributes

        private enum CodingKeys: String, CodingKey {
            case userId = "UserId", attributes = "Attributes"
        }
    }

    struct Attributes: Decodable {
        let type: MessageType
        let stickerSrc: String

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let rawType = try container.decode(String.self, forKey: .type)
            self.type = MessageType(rawValue: rawType) ?? .message
            self.stickerSrc = try container.decode(String.self, forKey: .stickerSrc)
        }

        private enum CodingKeys: String, CodingKey {
            case type = "message_type", stickerSrc = "sticker_src"
        }
    }

    var id: String
    let objectType: MessageObjectType
    let type: MessageType
    let requestId: String
    let content: String
    let attributes: Attributes?
    let sendTime: String
    let sender: Sender

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.objectType = .message
        let rawType = try container.decode(String.self, forKey: .type)
        self.type = MessageType(rawValue: rawType) ?? .message
        self.requestId = try container.decode(String.self, forKey: .requestId)
        self.content = try container.decode(String.self, forKey: .content)
        self.attributes = try? container.decode(Attributes.self, forKey: .attributes)
        self.sendTime = try container.decode(String.self, forKey: .sendTime)
        self.sender = try container.decode(Sender.self, forKey: .sender)
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    private enum CodingKeys: String, CodingKey {
        case id = "Id"
        case type = "Type"
        case requestId = "RequestId"
        case content = "Content"
        case attributes = "Attributes"
        case sendTime = "SendTime"
        case sender = "Sender"
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
