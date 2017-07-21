//
//  DataWriter.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 9/12/16.
//

import Foundation

public protocol DataWriterProtocol {
    var buffer: Data { get }

    func write<T: EndianProtocol>(_ val: T, endian: Endian) throws
    func writeData(_ d: Data) throws
}

public class DataWriter: DataWriterProtocol {
    public var buffer = Data()

    public func write<T: EndianProtocol>(_ val: T, endian: Endian = .Big) {
        var eval: T

        switch endian {
        case .Big:
            eval = val.bigEndian
        case .Little:
            eval = val.littleEndian
        }

        buffer.append(UnsafeBufferPointer(start: &eval, count: 1))
    }

    public func write<T: EndianEnumProtocol>(_ val: T, endian: Endian = .Big) {
        write(val.rawValue)
    }

    public func writeData(_ d: Data) {
        buffer.append(d)
    }
}

public enum CappedDataWriterError: Error {
    case MaxExceeded
}

public class CappedDataWriter: DataWriterProtocol {
    public var max: Int
    public var buffer: Data { return writer.buffer }
    public var isFinished: Bool { return buffer.count == max }

    private let writer = DataWriter()

    public init(max m: Int) {
        max = m
    }

    public func write<T: EndianProtocol>(_ val: T, endian: Endian = .Big) throws {
        if buffer.count + MemoryLayout<T>.size > max {
            throw CappedDataWriterError.MaxExceeded
        }

        writer.write(val, endian: endian)
    }

    public func writeData(_ d: Data) throws {
        if buffer.count + d.count > max {
            throw CappedDataWriterError.MaxExceeded
        }

        writer.writeData(d)
    }
}
