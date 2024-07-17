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
    var message: String = ""

    private init() {
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
            print(text)
            
            DispatchQueue.main.async {
                self.message = text
                
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
