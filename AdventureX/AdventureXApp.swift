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
    @StateObject private var positionData = PositionData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .environmentObject(positionData)
        }
        .windowStyle(.volumetric)
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .environmentObject(positionData)
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
