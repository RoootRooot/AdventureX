//
//  PositionData.swift
//  AdventureX
//
//  Created by GH on 7/16/24.
//

import Combine
import Foundation
import simd

class PositionData: ObservableObject {
    @Published var positions: [SIMD3<Float>] = []
        
    func generateRandomPositions(count: Int) {
        positions = (0..<count).map { _ in
            SIMD3<Float>(
                Float.random(in: -0.9...0.9),
                Float.random(in: -0.9...0.9),
                Float.random(in: -0.9...0.9)
            )
        }
    }
}
