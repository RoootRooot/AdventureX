//
//  Socket.swift
//  AdventureX
//
//  Created by GH on 7/17/24.
//

import Starscream
import Foundation
import Observation

@Observable
class WebSocketManager: WebSocketDelegate {
    var socket: WebSocket!
    var message: String = ""

    init() {
        var request = URLRequest(url: URL(string: "ws://192.168.43.109:8765")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("WebSocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            print("WebSocket is disconnected: \(reason) with code: \(code)")
        case .text(let text):
            print("Received text: \(text)")
            DispatchQueue.main.async {
                self.message = text
            }
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            print("WebSocket cancelled")
        case .peerClosed:
            print("peerClosed")
        case .error(let error):
            print("WebSocket encountered an error: \(String(describing: error))")
        }
    }
}
