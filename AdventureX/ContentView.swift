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
    @Binding var rotationAngle: Float
    @State private var rotationTimer: Timer?

    var body: some View {
        RealityView { content in
            
        } update: { content in
            updateContent(with: positionData.frames)
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack {
                    ToggleImmersiveSpaceButton()
                    HStack {
                        Button {
                            toggleRotatingLeft()
                        } label: {
                            VStack {
                                Image(systemName: "rotate.left")
                                    .font(.title)
                                Text("左旋转")
                                    .font(.caption)
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            toggleRotatingRight()
                        } label: {
                            VStack {
                                Image(systemName: "rotate.right")
                                    .font(.title)
                                Text("右旋转")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: positionData.frames) { oldFrames, newFrames in
            updateContent(with: newFrames)
        }
    }
    
    private func toggleRotatingLeft() {
        if rotationTimer == nil {
            startRotatingLeft()
        } else {
            stopRotating()
        }
    }
    
    private func toggleRotatingRight() {
        if rotationTimer == nil {
            startRotatingRight()
        } else {
            stopRotating()
        }
    }
    
    private func startRotatingLeft() {
        rotationTimer?.invalidate()
        rotationTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            rotationAngle += .pi / 360
        }
    }
    
    private func startRotatingRight() {
        rotationTimer?.invalidate()
        rotationTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            rotationAngle -= .pi / 360
        }
    }
    
    private func stopRotating() {
        rotationTimer?.invalidate()
        rotationTimer = nil
    }

    private func updateContent(with frames: [Frame]) {
        // 更新 RealityView 的内容
    }
}

#Preview(windowStyle: .plain) {
    ContentView(rotationAngle: .constant(0))
        .environment(PositionData.shared)
}
