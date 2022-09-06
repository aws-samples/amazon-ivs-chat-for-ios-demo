//
//  TokenRequest.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 26/08/2022.
//

import Foundation

struct TokenRequest: Codable {
    enum UserCapability: String, Codable {
        case deleteMessage = "DELETE_MESSAGE"
        case disconnectUser = "DISCONNECT_USER"
        case sendMessage = "SEND_MESSAGE"
    }

    enum TokenRequestError: Error {
        case serverNotSet
    }

    let arn: String
    let awsRegion: String
    let durationInMinutes: Int
    let attributes: [String : String]
    let capabilities: [UserCapability]
    var user: User?

    func fetchResponse() async throws -> Data {
        print("ℹ Requesting new auth token")
        guard let url = URL(string: Constants.apiUrl) else {
            print("❌ Server url not set in Constats.swift")
            throw TokenRequestError.serverNotSet
        }
        let authSession = URLSession(configuration: .default)
        var authRequest = URLRequest(url: url)
        authRequest.httpMethod = "POST"
        authRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        authRequest.httpBody = """
            {
                "roomIdentifier": "\(Constants.chatRoomId)",
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

        return try await authSession.data(for: authRequest).0
    }
}
