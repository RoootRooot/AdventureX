//
//  DataModel.swift
//  AdventureX
//
//  Created by GH on 7/16/24.
//

import simd
import Combine
import Foundation

struct Frame: Equatable {
    let id = UUID()
    let positions: [SIMD3<Float>]

    static func ==(lhs: Frame, rhs: Frame) -> Bool {
        return lhs.id == rhs.id
    }
}

class PositionData: ObservableObject {
    static let shared = PositionData(frameCount: 10)

    @Published private(set) var frames: [Frame] = []
    private var ringBuffer: RingBuffer<Frame>
    private var updateQueue = DispatchQueue(label: "PositionDataUpdateQueue")

    private init(frameCount: Int) {
        ringBuffer = RingBuffer(size: frameCount)
    }

    func generateRandomPoints(count: Int) {
        updateQueue.async {
            let positions = (0..<count).map { _ in
                SIMD3<Float>(
                    Float.random(in: -0.9...0.9),
                    Float.random(in: -0.9...0.9),
                    Float.random(in: -0.9...0.9)
                )
            }
            let frame = Frame(positions: positions)
            self.ringBuffer.write(frame)

            let frames = self.ringBuffer.read()
            DispatchQueue.main.async {
                self.frames = frames
                self.removeOldestFramesIfNeeded()
                print("Generated frame with \(frame.positions.count) positions")
            }
        }
    }

    private func removeOldestFramesIfNeeded() {
        if frames.count > 10 {
            frames.removeFirst(frames.count - 10)
        }
    }
}

class RingBuffer<T> {
    private var buffer: [T?]
    private var readIndex = 0
    private var writeIndex = 0
    private let size: Int
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
