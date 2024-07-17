//
//  ContentView.swift
//  AdventureX
//
//  Created by GH on 7/16/24.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(PositionData.self) var positionData
    @State private var isGeneratingPoints = false
    @State private var timer: Timer?

    var body: some View {
        RealityView { content in
            
        } update: { content in
            updateContent(with: positionData.frames)
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack {
                    ToggleImmersiveSpaceButton()
                }
            }
        }
        .onChange(of: positionData.frames) { oldFrames, newFrames in
            updateContent(with: newFrames)
        }
    }

    private func updateContent(with frames: [Frame]) {
        
    }
}

//#Preview(windowStyle: .volumetric) {
//    ContentView()
//        .environment(PositionData.shared)
//}
