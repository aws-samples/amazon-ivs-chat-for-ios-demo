//
//  Response.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 02/03/2022.
//

import Foundation

enum ResponseType: String {
    case error, message, event
}

struct EventAttributes: Decodable {
    let messageId: String?
    let userId: String?
    let reason: String?

    private enum CodingKeys: String, CodingKey {
        case messageId = "MessageID"
        case userId = "userId"
        case reason = "reason"
    }
}

struct Response: Decodable {
    let type: ResponseType
    let id: String?
    let sendTime: String?
    let eventName: String?
    let eventAttributes: EventAttributes?
    let errorCode: Int?
    let errorMessage: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawType = try container.decode(String.self, forKey: .type).lowercased()
        self.type = ResponseType(rawValue: rawType) ?? .error
        self.id = try? container.decode(String.self, forKey: .id)
        self.sendTime = try? container.decode(String.self, forKey: .sendTime)

        self.eventName = try? container.decode(String.self, forKey: .eventName)
        self.eventAttributes = try? container.decode(EventAttributes.self, forKey: .eventAttributes)

        self.errorCode = try? container.decode(Int.self, forKey: .errorCode)
        self.errorMessage = try? container.decode(String.self, forKey: .errorMessage)
    }

    private enum CodingKeys: String, CodingKey {
        case id = "Id"
        case type = "Type"
        case sendTime = "SendTime"
        case eventName = "EventName"
        case eventAttributes = "Attributes"
        case errorCode = "ErrorCode"
        case errorMessage = "ErrorMessage"
    }
}
