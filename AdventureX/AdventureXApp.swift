//
//  AdventureXApp.swift
//  AdventureX
//
//  Created by GH on 7/16/24.
//

import SwiftUI

@main
struct AdventureXApp: App {
    @State private var appModel = AppModel()
    @State private var rotationAngle: Float = 0.0
    
    init() {
        WebSocketManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(rotationAngle: $rotationAngle)
                .environment(appModel)
                .environment(PositionData.shared)
        }
        .windowStyle(.plain)
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView(rotationAngle: $rotationAngle)
                .environment(appModel)
                .environment(PositionData.shared)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                    WebSocketManager.shared.socket.connect()
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                    WebSocketManager.shared.socket.disconnect()
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
