//
//  Socket.swift
//  AdventureX
//
//  Created by GH on 7/17/24.
//

import Foundation
import SocketIO

class NetworkManager {
    static let shared = NetworkManager()
    private var manager: SocketManager
    private var socket: SocketIOClient

    private init() {
        self.manager = SocketManager(socketURL: URL(string: "ws://192.168.43.109:8765")!, config: [.log(true), .compress, .forceWebsockets(true)])
        self.socket = manager.defaultSocket
        addHandlers()
        socket.connect()
    }
    
    private func addHandlers() {
        socket.on(clientEvent: .connect) { data, ack in
            print("Socket connected")
        }

        socket.on(clientEvent: .disconnect) { data, ack in
            print("Socket disconnected")
        }
    }
    
    func disconnect() {
        socket.disconnect()
    }
}
