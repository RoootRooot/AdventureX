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
    @State private var isGeneratingPoints = false
    @State private var timer: Timer?

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

                    Button(isGeneratingPoints ? "Stop Generating Points" : "Start Generating Points") {
                        isGeneratingPoints.toggle()
                        if isGeneratingPoints {
                            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                                positionData.generateRandomPoints(count: 50)
                            }
                        } else {
                            timer?.invalidate()
                            timer = nil
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
        // Update RealityKit content with the new frames
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
        .environment(AppModel())
        .environmentObject(PositionData.shared)
}
