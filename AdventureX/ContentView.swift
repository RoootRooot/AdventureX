//
//  ContentView.swift
//  AdventureX
//
//  Created by GH on 7/16/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @EnvironmentObject var positionData: PositionData

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(scene)
            }
        } update: { content in
            // Update the RealityKit content when SwiftUI state changes
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack {
                    ToggleImmersiveSpaceButton()
                    
                    Button("Refresh Positions") {
                        positionData.generateRandomPositions(count: 1000)
                    }
                }
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
        .environment(AppModel())
        .environmentObject(PositionData())
}
