//
//  DataWriter.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/12/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import Foundation

protocol DataWriterProtocol {
    var buffer: Data { get }

    func write<T: EndianProtocol>(_ val:T, endian: Endian) throws
    func writeData(_ d: Data) throws
}

class DataWriter: DataWriterProtocol {
    var buffer = Data()
    
    func write<T: EndianProtocol>(_ val:T, endian: Endian = .Big) {
        var eval: T
        
        switch endian {
        case .Big:
            eval = val.bigEndian
        case .Little:
            eval = val.littleEndian
        }

        buffer.append(UnsafeBufferPointer(start: &eval, count: 1))
    }
    
    func writeData(_ d: Data) {
        buffer.append(d)
    }
}

class CappedDataWriter: DataWriterProtocol {
    enum CDWError: Error {
        case MaxExceeded
    }
    
    var max: Int
    var buffer: Data { return writer.buffer }
    var isFinished: Bool { return buffer.count == max }
    
    private let writer = DataWriter()
    
    init(max m:Int) {
        max = m
    }
    
    func write<T: EndianProtocol>(_ val:T, endian: Endian = .Big) throws {
        if buffer.count + MemoryLayout<T>.size > max {
            throw CDWError.MaxExceeded
        }
        
        writer.write(val, endian: endian)
    }
    
    func writeData(_ d: Data) throws {
        if buffer.count + d.count > max {
            throw CDWError.MaxExceeded
        }
        
        writer.writeData(d)
    }
}
