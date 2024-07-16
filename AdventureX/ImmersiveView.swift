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
    @EnvironmentObject var positionData: PositionData
    @State private var anchor = AnchorEntity(world: .zero)
    @State private var pointEntities: [UUID: [ModelEntity]] = [:]

    var body: some View {
        RealityView { content in
            content.add(anchor)
        }
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                positionData.generateRandomPoints(count: 50)
            }
        }
        .onChange(of: positionData.frames) { oldFrames, newFrames in
            DispatchQueue.global(qos: .userInitiated).async {
                self.updateContent(oldFrames: oldFrames, newFrames: newFrames)
            }
        }
    }

    private func updateContent(oldFrames: [Frame], newFrames: [Frame]) {
        DispatchQueue.main.async {
            let oldFrameIDs = Set(oldFrames.map { $0.id })
            let newFrameIDs = Set(newFrames.map { $0.id })

            let framesToRemove = oldFrameIDs.subtracting(newFrameIDs)
            for frameID in framesToRemove {
                if let entities = self.pointEntities.removeValue(forKey: frameID) {
                    for entity in entities {
                        self.anchor.removeChild(entity)
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
                        let cubeEntity = ModelEntity(mesh: cubeMesh, materials: [cubeMaterial])
                        cubeEntity.position = position
                        cubeEntity.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: [0.04, 0.04, 0.04])])
                        entities.append(cubeEntity)
                    }
                    for entity in entities {
                        self.anchor.addChild(entity)
                    }
                    self.pointEntities[frame.id] = entities
                }
            }

            let boxMesh = MeshResource.generateBox(size: [1.8, 1.8, 1.8])
            let boxMaterial = SimpleMaterial(color: .clear, isMetallic: false)
            let boxEntity = ModelEntity(mesh: boxMesh, materials: [boxMaterial])
//            boxEntity.position = [0, 1, -4]
            self.anchor.addChild(boxEntity)
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
        .environmentObject(PositionData.shared)
}
