//
//  DataModel.swift
//  AdventureX
//
//  Created by GH on 7/16/24.
//

import simd
import Foundation
import Observation

struct Frame: Equatable, Identifiable {
    let id: UUID
    let frameNum: Int
    let positions: [SIMD3<Float>] // 3D 浮点数向量
    
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
    
    private init(frameCount: Int) {
        ringBuffer = RingBuffer(size: frameCount)
    }
    
    func generatePoints(from json: [String: Any]) {
        updateQueue.async {
            // 提取 JSON 字段参考自 ChatGPT
            guard let pointCloudData = PointCloud(JSON: json),
                  let pointCloud = pointCloudData.pointCloud,
                  let frameNum = pointCloudData.frameNum else {
                print("Invalid JSON format or missing pointCloud data")
                return
            }
            
            let positions: [SIMD3<Float>] = pointCloud.compactMap {
                guard $0.count >= 3 else { return nil }
                return SIMD3<Float>(
                    Float($0[0]),
                    Float($0[2]),
                    -Float($0[1])
                )
            }
            
            let frame = Frame(id: UUID(), frameNum: frameNum, positions: positions)
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
            frames.removeFirst(frames.count - 10)
        }
    }
    
    func clearFrames() {
        updateQueue.async {
            self.ringBuffer = RingBuffer(size: self.ringBuffer.size)
            DispatchQueue.main.async {
                self.frames.removeAll()
            }
        }
    }
}

// 环形缓冲区参考自 ChatGPT
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
