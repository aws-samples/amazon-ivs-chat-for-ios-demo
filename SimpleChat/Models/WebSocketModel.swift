//
//  WebSocketModel.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 06/09/2021.
//  

import Foundation
import SwiftUI

class WebSocketModel: ObservableObject {
    private let socket = URL(string: Constants.chatWebsocket)!
    private let session = URLSession(configuration: .default)

    private var request: URLRequest
    private var webSocketTask: URLSessionWebSocketTask?
    private var authToken: String?
    private var isReady = true
    private var authInProgress = false

    private var authTokenTimer: Timer?
    private var authTokenReceiveTimestamp: Date? {
        didSet {
            authTokenTimer?.invalidate()
            authTokenTimer = Timer.scheduledTimer(timeInterval: 55,
                                                  target: self,
                                                  selector: #selector(getNewAuthTokenAfterTimeout),
                                                  userInfo: nil,
                                                  repeats: false)
        }
    }

    var viewModel: ViewModel?
    @Published var messages: [AnyHashable] = []
    @Published var errorMessage: String?
    @Published var successMessage: String?

    init() {
        request = URLRequest(url: socket)
        authenticateForReceivingMessages()
    }

    deinit {
        authTokenTimer?.invalidate()
    }

    func authenticate() {
        guard let user = viewModel?.user else {
            logout()
            return
        }
        authToken = nil
        webSocketTask?.cancel()
        print("ℹ Authenticating user")
        if authToken == nil {
            getAuthToken(for: user) { [weak self] in
                print("ℹ Got auth token")
                DispatchQueue.main.async {
                    self?.viewModel?.isAuthorised = self?.authenticateAndStartListening() ?? false
                }
            }
        } else {
            DispatchQueue.main.async {
                self.viewModel?.isAuthorised = self.authenticateAndStartListening()
            }
        }
    }

    func logout() {
        webSocketTask?.cancel()
        authToken = nil
        DispatchQueue.main.async {
            if let _ = self.viewModel?.user {
                self.viewModel?.isAuthorised = false
                self.viewModel?.user = nil
            }
        }
        authenticateForReceivingMessages()
    }

    func sendMessage(_ message: String, type: MessageType, avatarUrl: String) {
        var payload = ""
        switch type {
            case .message:
                payload = """
                    {
                     "id": "\(UUID().uuidString)",
                     "action": "SEND_MESSAGE",
                     "content": "\(message)"
                    }
                """
            case .sticker:
                payload = """
                    {
                     "id": "\(UUID().uuidString)",
                     "action": "SEND_MESSAGE",
                     "content": "Sticker",
                     "attributes": {
                        "message_type": "STICKER",
                        "sticker_src": "\(message)"
                     }
                    }
                """
        }
        sendWebsocketTask(with: payload)
    }

    func delete(message id: String) {
        let payload = """
            {
             "id": "\(id)",
             "action": "DELETE_MESSAGE",
             "reason": "Deleted by moderator"
            }
        """
        sendWebsocketTask(with: payload) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.successMessage = "Message deleted"
                } else {
                    self?.errorMessage = "Could not delete message"
                }
            }
        }
    }

    func kick(user id: String) {
        let payload = """
            {
             "userId": "\(id)",
             "action": "DISCONNECT_USER",
             "reason": "Kicked by moderator"
            }
        """
        sendWebsocketTask(with: payload) { [weak self] success in
            if success {
                self?.sendEvent(
                    name: "app:DELETE_BY_USER",
                    attributes: """
                        {
                            "userId": "\(id)"
                        }
                    """)
                DispatchQueue.main.async {
                    self?.successMessage = "User kicked"
                }
            }
        }
    }

    private func sendWebsocketTask(with payload: String, completion: ((Bool) -> Void)? = nil) {
        webSocketTask?.send(URLSessionWebSocketTask.Message.string(payload)) { [weak self] error in
            if let error = error {
                print("❌ Failed to send payload: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                completion?(false)
            } else {
                print("✅ Payload sent: \(payload)")
                completion?(true)
            }
        }
        webSocketTask?.resume()
    }

    private func sendEvent(name: String, attributes: String) {
        guard let url = URL(string: "\(Constants.apiUrl)/event") else {
            print("❌ Server url not set in Constats.swift")
            return
        }
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = """
            {
                "arn": "\(Constants.chatRoomId)",
                "eventName": "\(name)",
                "eventAttributes": \(attributes)
            }
        """.data(using: .utf8)
        request.timeoutInterval = 10

        session.dataTask(with: request) { [weak self] data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("❌ Got status code \(httpResponse.statusCode) when sending event")
                    if let data = data, let response = String(data: data, encoding: .utf8) {
                        print(response)
                        DispatchQueue.main.async {
                            self?.errorMessage = response
                        }
                    }
                    return
                }

                if let error = error {
                    print("❌ Failed to send event: \(error)")
                    DispatchQueue.main.async {
                        self?.errorMessage = error.localizedDescription
                    }
                    return
                }

                print("✅ event with name '\(name)' sent successfully")
            }
        }.resume()
    }

    @objc
    private func getNewAuthTokenAfterTimeout() {
        if let _ = viewModel?.user {
            authenticate()
        } else {
            authenticateForReceivingMessages()
        }
    }

    private func authenticateForReceivingMessages() {
        if !authInProgress {
            authInProgress = true
            print("ℹ Authenticating for only receiving messages")
            getAuthToken(for: nil) { [weak self] in
                print("ℹ Got auth token for receiving messages")
                self?.authenticateAndStartListening()
            }
        }
    }

    private func getAuthToken(for user: User?, completion: @escaping () -> Void) {
        print("ℹ Requesting new auth token")
        guard let url = URL(string: "\(Constants.apiUrl)/auth") else {
            print("❌ Server url not set in Constats.swift")
            return
        }
        let authSession = URLSession(configuration: .default)
        var authRequest = URLRequest(url: url)
        authRequest.httpMethod = "POST"
        authRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        authRequest.httpBody = """
            {
                "arn": "\(Constants.chatRoomId)",
                "userId": "\(user != nil ? user!.id : UUID().uuidString)",
                "attributes": {
                    "username": "\(user != nil ? user!.username : "")",
                    "avatar": "\(user != nil ? user!.avatarUrl : "")"
                },
                "capabilities": [\(user == nil ? "" : "\"SEND_MESSAGE\"\(user!.isModerator ? ", \"DISCONNECT_USER\", \"DELETE_MESSAGE\"" : "")")],
                "durationInMinutes": 55
            }
        """.data(using: .utf8)
        authRequest.timeoutInterval = 10

        authSession.dataTask(with: authRequest) { [weak self] data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("❌ Got status code \(httpResponse.statusCode) when getting authorisation token")
                    if let data = data, let response = String(data: data, encoding: .utf8) {
                        print(response)
                        DispatchQueue.main.async {
                            self?.errorMessage = response
                        }
                    }
                    return
                }
            }

            if let error = error {
                print("❌ Failed to get authorisation token: \(error)")
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                return
            }

            guard let data = data else {
                print("❌ Got no data for authorisation token")
                completion()
                return
            }

            guard let token = String(data: data, encoding: .utf8) else {
                print("❌ Failed to cast received authorisation token data to String using UTF8 encoding")
                completion()
                return
            }
            self?.authToken = token
            self?.authTokenReceiveTimestamp = Date()
            completion()
        }.resume()
    }

    @discardableResult
    private func authenticateAndStartListening() -> Bool {
        isReady = true
        guard let token = authToken else {
            print("❌ Not authenticated")
            return false
        }
        request.setValue(token, forHTTPHeaderField: "Sec-WebSocket-Protocol")
        webSocketTask = session.webSocketTask(with: request)
        print("ℹ Authenticated")
        authInProgress = false
        startListening()
        return true
    }

    private func startListening() {
        print("ℹ Starting listening to websocket...")
        getMessages()
        webSocketTask?.resume()
        DispatchQueue.main.async {
            self.messages.append(SuccessMessage(text: "Connected to chat"))
        }
    }

    private func getMessages() {
        guard isReady == true else {
            print("⚠️ WebsocketModel is not ready")
            return
        }

        webSocketTask?.receive { [weak self] result in
            switch result {
                case .failure(let error):
                    print("❌ Failed to receive message: \(error)")
                    self?.isReady = false
                    self?.webSocketTask?.cancel()
                    self?.logout()
                    DispatchQueue.main.async {
                        self?.errorMessage = "Disconnected from chat"
                    }
                case .success(let message):
                    switch message {
                        case .string(let text):
                            print("ℹ Received: \(text)")
                            if let response: Response = self?.decode(text) {
                                switch response.type {
                                    case .message:
                                        if let message: Message = self?.decode(text) {
                                            print("✅ Received text message decoded")
                                            DispatchQueue.main.async {
                                                self?.messages.append(message)
                                            }
                                        }
                                    case .error:
                                        guard let error = response.errorMessage else {
                                            print("❌ Received error has no error message")
                                            DispatchQueue.main.async {
                                                self?.errorMessage = "Received error with no message"
                                            }
                                            return
                                        }
                                        let code = response.errorCode != nil ? "(\(response.errorCode!))" : "()"
                                        print("❌ Received error: \(error) \(code)")
                                        DispatchQueue.main.async {
                                            if response.errorCode == 429 {
                                                self?.messages.append(ErrorMessage(text: "Error 429", details: error))
                                            } else {
                                                self?.errorMessage = "Error \(code) \(error)"
                                            }
                                        }
                                    case .event:
                                        print("ℹ Received event: \(response.eventName ?? "nil")")
                                        if response.eventName == "aws:DELETE_MESSAGE" {
                                            // Remove local message after successful message DELETE event
                                            if let messageId = response.eventAttributes?.messageId,
                                               let index = self?.messages
                                                .firstIndex(where: { obj in
                                                    if let message = obj as? Message {
                                                        return message.id == messageId
                                                    }
                                                    return false
                                                }) {
                                                DispatchQueue.main.async {
                                                    self?.messages.remove(at: index)
                                                }
                                            } else {
                                                print("❌ Could not remove local message, reason: no message found (id: \(response.eventAttributes?.messageId ?? "nil"))")
                                            }
                                        } else if response.eventName == "app:DELETE_BY_USER" {
                                            // Remove local messages from the removed user
                                            guard let userId = response.eventAttributes?.userId else {
                                                print("❌ no userId received in event")
                                                return
                                            }
                                            self?.messages.forEach { msg in
                                                guard let message = msg as? Message else {
                                                    return
                                                }

                                                DispatchQueue.main.async {
                                                    if message.sender.userId == userId,
                                                       let index = self?.messages.firstIndex(where: { obj in
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

                                                        if let self = self, index < self.messages.count {
                                                            self.messages.remove(at: index)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                }
                            }
                        case .data(let data):
                            print("✅ Received binary message: \(data)")
                        @unknown default:
                            fatalError()
                    }
            }

            self?.getMessages()
        }
    }

    private func decode(_ message: String) -> Message? {
        do {
            return try JSONDecoder().decode(Message.self, from: message.data(using: .utf8)!)
        } catch {
            print("❌ Could not decode message: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Could not decode received message"
            }
            return nil
        }
    }

    private func decode(_ response: String) -> Response? {
        do {
            return try JSONDecoder().decode(Response.self, from: response.data(using: .utf8)!)
        } catch {
            print("❌ Could not decode response: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Could not decode response"
            }
            return nil
        }
    }
}
