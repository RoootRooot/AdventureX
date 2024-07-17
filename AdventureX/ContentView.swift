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
                    
                    Button(isGeneratingPoints ? "Stop Generating Points" : "Start Generating Points") {
                        isGeneratingPoints.toggle()
                        if isGeneratingPoints {
                            startGeneratingPoints()
                        } else {
                            stopGeneratingPoints()
                        }
                    }
                }
            }
        }
        .onChange(of: positionData.frames) { oldFrames, newFrames in
            updateContent(with: newFrames)
        }
    }

    private func updateContent(with frames: [Frame]) {
        
    }

    private func startGeneratingPoints() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            positionData.generateRandomPoints(count: 50)
        }
    }

    private func stopGeneratingPoints() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
        .environment(PositionData.shared)
}
