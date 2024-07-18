//
//  ImmersiveView.swift
//  AdventureX
//
//  Created by GH on 7/16/24.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @Environment(PositionData.self) var positionData
    @State private var anchor = AnchorEntity(world: .zero)
    @State private var boxEntity = ModelEntity()
    @State private var pointEntities: [UUID: [ModelEntity]] = [:]
    @State private var isBoxCreated = false
    @State private var currentScale: Float = 1.0
    @State private var currentRotation: simd_quatf = simd_quatf(angle: 0, axis: [0, 1, 0])
    @State private var currentPosition: SIMD3<Float> = [0, 1, -4]
    
    @Binding var rotationAngle: Float
    
    var body: some View {
        RealityView { content in
            content.add(anchor)
        }
        .onAppear {
            if !isBoxCreated {
                createBox()
                isBoxCreated = true
            }
        }
        .onDisappear {
            clearBox()
            isBoxCreated = false
        }
        .onChange(of: positionData.frames) { oldFrames, newFrames in
            DispatchQueue.global(qos: .userInitiated).async {
                self.updateContent(oldFrames: oldFrames, newFrames: newFrames)
            }
        }
        .onChange(of: rotationAngle) { newAngle in
            rotateBox(to: newAngle)
        }
        .gesture(
            SimultaneousGesture(
                DragGesture().onChanged { value in
                    let translation = value.translation
                    currentPosition.x += Float(translation.width) * 0.00005
                    currentPosition.y -= Float(translation.height) * 0.00005
                    boxEntity.position = currentPosition
                },
                MagnificationGesture().onChanged { value in
                    let scaleDelta = Float(value.magnitude - 1.0) * 0.1 + 1.0
                    currentScale *= scaleDelta
                    boxEntity.scale = [currentScale, currentScale, currentScale]
                }
            )
        )
    }
    
    private func createBox() {
        let boxMesh = MeshResource.generateBox(size: [1.8, 1.8, 1.8])
        let boxMaterial = SimpleMaterial(color: .clear, isMetallic: false)
        
        boxEntity = ModelEntity(mesh: boxMesh, materials: [boxMaterial])
        boxEntity.position = [0, 1, -4]
        
        boxEntity.components[CollisionComponent.self] = CollisionComponent(shapes: [.generateBox(size: [1.8, 1.8, 1.8])])
        boxEntity.components[InputTargetComponent.self] = InputTargetComponent()
        
        self.anchor.addChild(boxEntity)
        
        let sphereMesh = MeshResource.generateSphere(radius: 0.3)
        
        // Red sphere for X
        let redMaterial = SimpleMaterial(color: .red, isMetallic: false)
        let redSphere = ModelEntity(mesh: sphereMesh, materials: [redMaterial])
        redSphere.position = [1, 0, 0]
        
        // Green sphere for Y
        let greenMaterial = SimpleMaterial(color: .green, isMetallic: false)
        let greenSphere = ModelEntity(mesh: sphereMesh, materials: [greenMaterial])
        greenSphere.position = [0, 1, 0]
        
        // Blue sphere for Z
        let blueMaterial = SimpleMaterial(color: .blue, isMetallic: false)
        let blueSphere = ModelEntity(mesh: sphereMesh, materials: [blueMaterial])
        blueSphere.position = [0, 0, 1]
        
        boxEntity.addChild(redSphere)
        boxEntity.addChild(greenSphere)
        boxEntity.addChild(blueSphere)
    }
    
    private func rotateBox(to newAngle: Float) {
        let rotationDelta = simd_quatf(angle: newAngle, axis: [0, 1, 0])
        currentRotation = rotationDelta
        boxEntity.transform.rotation = currentRotation
    }
    
    private func clearBox() {
        boxEntity.removeFromParent()
        for (_, entities) in pointEntities {
            for entity in entities {
                entity.removeFromParent()
            }
        }
        pointEntities.removeAll()
    }
    
    private func updateContent(oldFrames: [Frame], newFrames: [Frame]) {
        DispatchQueue.main.async {
            let oldFrameIDs = Set(oldFrames.map { $0.id })
            let newFrameIDs = Set(newFrames.map { $0.id })
            
            let framesToRemove = oldFrameIDs.subtracting(newFrameIDs)
            
            for frameID in framesToRemove {
                if let entities = self.pointEntities.removeValue(forKey: frameID) {
                    for entity in entities {
                        self.boxEntity.removeChild(entity)
                    }
                }
            }
            
            let cubeMesh = MeshResource.generateBox(size: 0.04)
            let cubeMaterial = SimpleMaterial(color: .white, roughness: 1.0, isMetallic: false)
            
            let framesToAdd = newFrameIDs.subtracting(oldFrameIDs)
            
            for frame in newFrames {
                if framesToAdd.contains(frame.id) {
                    var entities = [ModelEntity]()
                    
                    for position in frame.positions {
                        let cube = ModelEntity(mesh: cubeMesh, materials: [cubeMaterial])
                        cube.position = position
                        cube.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: [0.02, 0.02, 0.02])])
                        
                        entities.append(cube)
                    }
                    
                    for entity in entities {
                        self.boxEntity.addChild(entity)
                    }
                    
                    self.pointEntities[frame.id] = entities
                }
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView(rotationAngle: .constant(0))
        .environment(PositionData.shared)
}
