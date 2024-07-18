//
//  Socket.swift
//  AdventureX
//
//  Created by GH on 7/17/24.
//

import SwiftyJSON
import Starscream
import Foundation
import Observation
import ObjectMapper

@Observable
class WebSocketManager: WebSocketDelegate {
    static let shared = WebSocketManager()
    
    var socket: WebSocket!
    private var reconnectTimer: Timer?
    private var isConnected: Bool = false
    
    private init() {
        var request = URLRequest(url: URL(string: "ws://192.168.43.131:8765")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        connect()
    }
    
    func connect() {
        if !isConnected {
            socket.connect()
        }
    }
    
    func disconnect() {
        isConnected = false
        reconnectTimer?.invalidate()
        socket.disconnect()
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
            reconnectTimer?.invalidate()
            print("WebSocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("WebSocket is disconnected: \(reason) with code: \(code)")
            scheduleReconnect()
        case .text(let text):
            DispatchQueue.main.async {
                if let data = text.data(using: .utf8) {
                    let json = JSON(data)
                    PositionData.shared.generatePoints(from: json)
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
            scheduleReconnect()
        case .cancelled:
            isConnected = false
            print("WebSocket cancelled")
            scheduleReconnect()
        case .peerClosed:
            isConnected = false
            print("Peer closed connection")
            scheduleReconnect()
        case .error(let error):
            isConnected = false
            print("WebSocket encountered an error: \(String(describing: error))")
            scheduleReconnect()
        }
    }
    
    private func scheduleReconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.connect()
        }
    }
}

struct PointCloud: Mappable {
    var error: Int?
    var frameNum: Int?
    var pointCloud: [[Double]]?
    var numDetectedPoints: Int?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        error               <- map["error"]
        frameNum            <- map["frameNum"]
        pointCloud          <- map["pointCloud"]
        numDetectedPoints   <- map["numDetectedPoints"]
    }
}
