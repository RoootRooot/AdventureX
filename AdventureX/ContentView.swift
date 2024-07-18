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
    @State private var selectedView: DisplayView = .content
    @State var heabert: Int = 0
    
    var body: some View {
        RealityView { content in
            
        } update: { content in
            
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack {
                    Picker("View", selection: $selectedView) {
                        ForEach(DisplayView.allCases, id: \.self) { view in
                            Text(view.rawValue)
                                .tag(view)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if selectedView == .content {
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
                    } else {
                        Text("")
                    }
                }
                .padding()
                .frame(width: 400)
                .glassBackgroundEffect()
            }
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
}

#Preview(windowStyle: .plain) {
    ContentView(rotationAngle: .constant(0))
        .environment(PositionData.shared)
}

enum DisplayView: String, CaseIterable {
    case content = "Content View"
    case heartBeat = "HeartBeat View"
}

