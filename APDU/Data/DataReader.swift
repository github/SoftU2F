//
//  DataReader.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

public enum DataReaderError: Error {
    case End
    case TypeError
}

public class DataReader {
    let data: Data
    var offset: Int

    // How many bytes are left
    var remaining: Int { return data.count - offset }

    // The remaining data
    var rest: Data { return data.subdata(in: offset..<data.count) }

    init(data d: Data, offset o: Int = 0) {
        data = d
        offset = o
    }

    // Read a number from the data, advancing our offset into the data.
    func read<T:EndianProtocol>(endian: Endian = .Big) throws -> T {
        guard let val: T = peek(endian: endian) else { throw DataReaderError.End }
        offset += MemoryLayout<T>.size
        return val
    }

    // Read an optional number from the data, advancing our offset into the data.
    func read<T:EndianProtocol>(endian: Endian = .Big) -> T? {
        do {
            let val: T = try read()
            return val
        } catch {
            return nil
        }
    }

    // Read an enum from the data, advancing our offset into the data.
    func read<T:EndianEnumProtocol>(endian: Endian = .Big) throws -> T {
        guard let raw: T.RawValue = peek() else { throw DataReaderError.End }
        offset += MemoryLayout<T.RawValue>.size
        guard let val: T = T.init(rawValue: raw) else { throw DataReaderError.TypeError }
        return val
    }

    // Read an optional enum from the data, advancing our offset into the data.
    func read<T:EndianEnumProtocol>(endian: Endian = .Big) -> T? {
        do {
            let val: T = try read()
            return val
        } catch {
            return nil
        }
    }

    // Read a number from the data, without advancing our offset into the data.
    func peek<T:EndianProtocol>(endian: Endian = .Big) -> T? {
        if remaining < MemoryLayout<T>.size { return nil }

        let tmp = rest.withUnsafeBytes { (pointer: UnsafePointer<T>) -> T in
            return pointer.pointee
        }

        switch endian {
        case .Big:
            return T(bigEndian: tmp)
        case .Little:
            return T(littleEndian: tmp)
        }
    }

    // Read an enum from the data, without advancing our offset into the data.
    func peek<T:EndianEnumProtocol>(endian: Endian = .Big) -> T? {
        guard let raw: T.RawValue = peek() else {
            return nil
        }

        return T.init(rawValue: raw)
    }

    // Read n bytes from the data, advancing our offset into the data.
    func readData<I:Integer>(_ n: I) throws -> Data {
        let intN = Int(n.toIntMax())

        guard let d = peekData(intN) else {
            throw DataReaderError.End
        }

        offset += intN
        return d
    }

    // Read n bytes from the data, without advancing our offset into the data.
    func peekData<I:Integer>(_ n: I) -> Data? {
        let intN = Int(n.toIntMax())

        if remaining < intN {
            return nil
        }

        return rest.subdata(in: 0..<intN)
    }
}
