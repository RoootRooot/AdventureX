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

    var body: some View {
        RealityView { content in
            // Add the RealityKit content
            let anchor = AnchorEntity(world: .zero)
            content.add(anchor)
            
            // 透明盒子
            let box = MeshResource.generateBox(size: [1.8, 1.8, 1.8])
            let transparentMaterial = SimpleMaterial(color: .clear, isMetallic: false)
            let boxEntity = ModelEntity(mesh: box, materials: [transparentMaterial])
            boxEntity.position = [0, 1, -4]

            // 白色地板
            let floorEntity = ModelEntity(mesh: .generatePlane(width: 1.8, depth: 1.8))
            floorEntity.position = [0, -0.9, 0]
            floorEntity.model?.materials = [SimpleMaterial(color: .white, isMetallic: false)]

            boxEntity.addChild(floorEntity)

            let cubeMesh = MeshResource.generateBox(size: 0.04)
            let cubeMaterial = SimpleMaterial(color: .white, roughness: 1.0, isMetallic: false)

            for position in positionData.positions {
                let cubeEntity = ModelEntity(mesh: cubeMesh, materials: [cubeMaterial])
                cubeEntity.position = position
                cubeEntity.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: [0.04, 0.04, 0.04])])
                boxEntity.addChild(cubeEntity)
            }

            anchor.addChild(boxEntity)
        }
        .onAppear {
            positionData.generateRandomPositions(count: 1000)
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
        .environmentObject(PositionData())
}
