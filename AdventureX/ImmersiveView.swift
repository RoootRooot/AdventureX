//
//  ImmersiveView.swift
//  AdventureX
//
//  Created by GH on 7/16/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Environment(PositionData.self) var positionData
    @State private var anchor = AnchorEntity(world: .zero)
    @State private var boxEntity = ModelEntity()
    @State private var pointEntities: [UUID: [ModelEntity]] = [:]
    @State private var isBoxCreated = false
    
    var body: some View {
        RealityView { content in
            content.add(anchor)
        }
        .onAppear {
            if !isBoxCreated {
                createBox()
                isBoxCreated = true
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                positionData.generateRandomPoints(count: 50)
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
        .gesture(
            DragGesture().onChanged { value in
                let translation = value.translation
                let newRotation = simd_quatf(angle: Float(translation.width / 360), axis: [0, 1, 0])
                boxEntity.transform.rotation = newRotation
            }
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
    ImmersiveView()
        .environment(PositionData.shared)
}
