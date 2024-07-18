//
//  DataModel.swift
//  AdventureX
//
//  Created by GH on 7/16/24.
//

import simd
import Foundation
import Observation
import SwiftyJSON
import RealityKit

struct Frame: Equatable, Identifiable {
    let id = UUID()
    let frameNum: Int
    let positions: [(coordinates: SIMD3<Float>, snr: Int, trackIndex: Int)] // 3D 浮点数向量，SNR 和 TrackIndex
    let trackIndex: [Int]
    
    static func ==(lhs: Frame, rhs: Frame) -> Bool {
        return lhs.frameNum == rhs.frameNum
    }
}

@Observable
class PositionData {
    static let shared = PositionData(frameCount: 10)
    
    private(set) var frames: [Frame] = []
    private var ringBuffer: RingBuffer<Frame>
    private var updateQueue = DispatchQueue(label: "PositionDataUpdateQueue")
    var colorManager = TrackColorManager()
    
    private init(frameCount: Int) {
        ringBuffer = RingBuffer(size: frameCount)
    }
    
    func generatePoints(from json: JSON) {
        updateQueue.async {
            guard let frameNum = json["frameNum"].int,
                  let pointCloud = json["pointCloud"].array,
                  let trackIndexes = json["trackIndexes"].array else {
                      if !self.frames.isEmpty {
                          DispatchQueue.main.async {
                              self.frames.removeLast()
                          }
                      }
                return
            }
            
            let positions: [(SIMD3<Float>, Int, Int)] = pointCloud.enumerated().compactMap { (index, point) in
                guard point.count >= 4, index < trackIndexes.count else { return nil }
                let coordinates = SIMD3<Float>(
                    Float(point[0].doubleValue),
                    Float(point[2].doubleValue),
                    -Float(point[1].doubleValue) + 1.8
                )
                
                let snr = point[4].intValue
                let trackIndex = trackIndexes[index].intValue
                return (coordinates, snr, trackIndex)
            }
            
            let trackIndexesArray = trackIndexes.compactMap { $0.int }
            
            let frame = Frame(frameNum: frameNum, positions: positions, trackIndex: trackIndexesArray)
            self.ringBuffer.write(frame)
            
            let frames = self.ringBuffer.read()
            DispatchQueue.main.async {
                self.frames = frames
                self.removeOldestFrame()
            }
        }
    }
    
    private func removeOldestFrame() {
        if frames.count > 10 {
            let removedFrame = frames.removeFirst()
            removedFrame.trackIndex.forEach { trackIndex in
                colorManager.releaseColor(for: trackIndex)
            }
        }
    }
    
    func clearFrames() {
        updateQueue.async {
            self.ringBuffer = RingBuffer(size: self.ringBuffer.size)
            DispatchQueue.main.async {
                self.frames.removeAll()
                self.colorManager.reset()
            }
        }
    }
}

class RingBuffer<T> {
    private var buffer: [T?]
    private var readIndex = 0
    private var writeIndex = 0
    let size: Int // 缓冲区大小
    private var count = 0
    
    init(size: Int) {
        self.size = size
        self.buffer = [T?](repeating: nil, count: size)
    }
    
    func write(_ element: T) {
        buffer[writeIndex] = element
        writeIndex = (writeIndex + 1) % size
        if count < size {
            count += 1
        } else {
            readIndex = (readIndex + 1) % size
        }
    }
    
    func read() -> [T] {
        var result = [T]()
        for i in 0..<count {
            let index = (readIndex + i) % size
            if let element = buffer[index] {
                result.append(element)
            }
        }
        return result
    }
    
    func latest() -> T? {
        return buffer[(writeIndex + size - 1) % size]
    }
}

class TrackColorManager {
    private var colors: [SimpleMaterial.Color] = [
        .red, .blue, .green, .yellow, .orange, .purple, .brown, .cyan, .magenta, .gray
    ]
    private var availableColors: [SimpleMaterial.Color]
    private var trackColorMap: [Int: (color: SimpleMaterial.Color, count: Int)] = [:] // count 用于引用计数
    
    init() {
        self.availableColors = colors
    }
    
    func color(for trackIndex: Int) -> SimpleMaterial.Color {
        if let (color, count) = trackColorMap[trackIndex] {
            trackColorMap[trackIndex]?.count = count + 1
            return color
        }
        if let color = availableColors.first {
            trackColorMap[trackIndex] = (color, 1)
            availableColors.removeFirst()
            return color
        }
        return .white
    }
    
    func releaseColor(for trackIndex: Int) {
        if var (color, count) = trackColorMap[trackIndex] {
            count -= 1
            if count == 0 {
                trackColorMap.removeValue(forKey: trackIndex)
                availableColors.append(color)
            } else {
                trackColorMap[trackIndex]?.count = count
            }
        }
    }
    
    func reset() {
        trackColorMap.removeAll()
        availableColors = colors
    }
}

// 使用颜色创建 SimpleMaterial
func createMaterial(for trackIndex: Int) -> SimpleMaterial {
    let color = PositionData.shared.colorManager.color(for: trackIndex)
    return SimpleMaterial(color: color, isMetallic: false)
}
