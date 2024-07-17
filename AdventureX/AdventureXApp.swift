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
    
    init() {
        NetworkManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .environment(PositionData.shared)
        }
        .windowStyle(.volumetric)
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .environment(PositionData.shared)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
