//
//  Reachability.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 10/09/2021.
//  

import SwiftUI
import Network

class NetworkConnection: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue.global(qos: .background)
    @Published var isConnected = true

    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
