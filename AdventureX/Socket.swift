//
//  Socket.swift
//  AdventureX
//
//  Created by GH on 7/17/24.
//

import Starscream
import Foundation
import Observation
import ObjectMapper

@Observable
class WebSocketManager: WebSocketDelegate {
    static let shared = WebSocketManager()
    
    var socket: WebSocket!
    var isConnected = false
    let reconnectDelay: TimeInterval = 1
    
    private init() {
        connect()
    }
    
    private func connect() {
        var request = URLRequest(url: URL(string: "ws://192.168.43.109:8765")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("WebSocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("WebSocket is disconnected: \(reason) with code: \(code)")
            reconnect()
        case .text(let text):
            DispatchQueue.main.async {
                if let json = text.data(using: .utf8),
                   let jsonObject = try? JSONSerialization.jsonObject(with: json, options: []) as? [String: Any] {
                    PositionData.shared.generatePoints(from: jsonObject)
                }
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
            reconnect()
        case .cancelled:
            isConnected = false
            print("WebSocket cancelled")
            reconnect()
        case .peerClosed:
            isConnected = false
            print("peerClosed")
            reconnect()
        case .error(let error):
            isConnected = false
            print("WebSocket encountered an error: \(String(describing: error))")
            reconnect()
        }
    }
    
    private func reconnect() {
        guard !isConnected else { return }
        DispatchQueue.global().asyncAfter(deadline: .now() + reconnectDelay) { [weak self] in
            self?.connect()
        }
    }
}
