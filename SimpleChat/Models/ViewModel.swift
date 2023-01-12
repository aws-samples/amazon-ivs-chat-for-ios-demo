//
//  ViewModel.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 06/09/2021.
//  

import AmazonIVSPlayer
import AmazonIVSChatMessaging

class ViewModel: ObservableObject {
    let playerModel = PlayerModel()

    private var tokenRequest: TokenRequest
    private var room: ChatRoom?

    @Published var isAuthorised: Bool = false
    @Published var messages: [AnyHashable] = []
    @Published var errorMessage: String?
    @Published var successMessage: String?

    @Published var user: User? {
        didSet {
            setupChatRoom()
            connectToChatRoom()
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
    @Published var useBulletChatMode: Bool {
        didSet {
            UserDefaults.standard.setValue(useBulletChatMode, forKey: Constants.kUseBulletChatMode)
        }
    }

    init() {
        let useCustomUrl = UserDefaults.standard.bool(forKey: Constants.kUseCustomLiveStreamUrl)
        let useBulletChat = UserDefaults.standard.bool(forKey: Constants.kUseBulletChatMode)
        self.useCustomStreamUrl = useCustomUrl
        self.useBulletChatMode = useBulletChat
        self.customPlaybackUrl = UserDefaults.standard.string(forKey: Constants.kLiveStreamUrl) ?? ""
        self.tokenRequest = TokenRequest(
            arn: Constants.chatRoomId,
            awsRegion: Constants.awsRegion,
            durationInMinutes: 180,
            attributes: [:],
            capabilities: [],
            user: nil)
        self.room = ChatRoom(awsRegion: tokenRequest.awsRegion) {
            let data = try await self.tokenRequest.fetchResponse()
            let authToken = try JSONDecoder().decode(AuthToken.self, from: data)
            return ChatToken(token: authToken.token)
        }
        room?.delegate = self
    }

    private func setupChatRoom() {
        self.tokenRequest = TokenRequest(
            arn: Constants.chatRoomId,
            awsRegion: Constants.awsRegion,
            durationInMinutes: 180,
            attributes: [:],
            capabilities: user != nil ? [.sendMessage, .deleteMessage, .disconnectUser] : [],
            user: user)
        if room != nil {
            self.room?.disconnect()
            self.room = nil
        }
        self.room = ChatRoom(awsRegion: tokenRequest.awsRegion) {
            let data = try await self.tokenRequest.fetchResponse()
            let authToken = try JSONDecoder().decode(AuthToken.self, from: data)
            return ChatToken(token: authToken.token)
        }
        room?.delegate = self
    }

    func connectToChatRoom() {
        Task(priority: .background) {
            if room?.state != .disconnected {
                room?.disconnect()
            }
            try await room?.connect()
        }
    }

    func startPlayback() {
        playerModel.play(useCustomStreamUrl ? customPlaybackUrl : Constants.playbackUrl)
    }

    func sendMessage(_ message: String, type: MessageType, avatarUrl: String) {
        var content = ""
        var attributes: Chat.Attributes = [:]
        switch type {
            case .message:
                content = message
                attributes = ["message_type": "MESSAGE"]
            case .sticker:
                content = "Sticker"
                attributes = ["message_type": "STICKER",
                              "sticker_src": "\(message)"]
        }

        room?.sendMessage(with: SendMessageRequest(content: content, attributes: attributes),
                          onSuccess: { _ in },
                          onFailure: { error in
            print("❌ error sending message: \(error)")
            self.errorMessage = error.localizedDescription
        })
    }

    func delete(message id: String) {
        room?.deleteMessage(with: DeleteMessageRequest(id: id, reason: "reason"),
                            onSuccess: { _ in
            DispatchQueue.main.async {
                self.successMessage = "Message deleted"
            }
        },
                            onFailure: { error in
            print("❌ error deleting message: \(error)")
            self.errorMessage = error.localizedDescription
        })
    }

    func kick(user id: String) {
        room?.disconnectUser(with: DisconnectUserRequest(id: id, reason: "Kicked by moderator"), onSuccess: { _ in
            DispatchQueue.main.async {
                self.successMessage = "User kicked"
            }
        })
    }
}

extension ViewModel: ChatRoomDelegate {
    func roomDidConnect(_ room: ChatRoom) {
        DispatchQueue.main.async {
            self.isAuthorised = self.user != nil
            if self.isAuthorised {
                self.messages.append(SuccessMessage(text: "Connected to chat"))
            }
        }
    }

    func roomDidDisconnect(_ room: ChatRoom) {
        DispatchQueue.main.async {
            if self.isAuthorised {
                self.messages.append(ErrorMessage(text: "Disconnected from chat", details: ""))
            }
            self.isAuthorised = false
        }
    }

    func room(_ room: ChatRoom, didDisconnect user: DisconnectedUser) {
        // Remove local messages from the removed user
        messages.forEach { msg in
            guard let message = msg as? Message else {
                return
            }
            DispatchQueue.main.async {
                if message.sender.id == user.userId,
                   let index = self.messages.firstIndex(where: { obj in
                       if let msg = obj as? Message {
                           return msg.id == message.id
                       } else if let msg = obj as? ErrorMessage {
                           return msg.id == message.id
                       } else if let msg = obj as? SuccessMessage {
                           return msg.id == message.id
                       } else {
                           return false
                       }
                   }) {

                    if index < self.messages.count {
                        self.messages.remove(at: index)
                    }
                }
            }
        }
    }

    func room(_ room: ChatRoom, didDelete message: DeletedMessage) {
        // Remove local message
        if let index = messages
            .firstIndex(where: { obj in
                if let msg = obj as? Message {
                    return msg.id == message.messageID
                }
                return false
            }) {
            DispatchQueue.main.async {
                self.messages.remove(at: index)
            }
        } else {
            print("❌ Could not remove local message, reason: no message found (id: \(message.messageID))")
        }
    }

    func room(_ room: ChatRoom, didReceive message: ChatMessage) {
        DispatchQueue.main.async {
            let msg = Message(
                id: message.id,
                objectType: .message,
                type: MessageType(rawValue: message.attributes?["message_type"] ?? "") ?? .message,
                requestId: message.requestId ?? UUID().uuidString,
                content: message.content,
                attributes: Message.Attributes(type: MessageType(rawValue: message.attributes?["message_type"] ?? "") ?? .message,
                                               stickerSrc: message.attributes?["sticker_src"] ?? ""),
                sendTime: "\(message.sendTime)",
                sender: User(id: message.sender.userId,
                             username: message.sender.attributes?["username"] ?? "",
                             avatarUrl: message.sender.attributes?["avatar"] ?? ""))
            self.messages.append(msg)
        }
    }

    func room(_ room: ChatRoom, didReceive event: ChatEvent) {
        print("⚠️ didReceive event \(event)")
    }
}
