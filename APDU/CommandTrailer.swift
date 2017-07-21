//
//  CommandTrailer.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/25/17.
//

import Foundation

public struct CommandTrailer: RawConvertible, MessagePart {
    let maxResponse: Int
    let noBody: Bool

    public var raw: Data {
        let writer = DataWriter()

        if noBody {
            writer.write(UInt8(0x00))
        }

        if maxResponse <= Int(UInt16.max) {
            writer.write(UInt16(maxResponse))
        } else {
            writer.write(UInt16(0x0000))
        }

        return writer.buffer
    }

    public init(reader: DataReader) throws {
        // 0 is prepended to trailer if there was no body.
        if reader.remaining == 3 {
            noBody = true
            let zero: UInt8 = try reader.read()
            if zero != 0x00 { throw ResponseStatus.WrongLength }
        } else {
            noBody = false
        }

        switch reader.remaining {
        case 0:
            maxResponse = 0
        case 1:
            throw ResponseStatus.WrongLength
        case 2:
            let mr: UInt16 = try reader.read()
            if mr == 0x0000 {
                maxResponse = MaxResponseSize
            } else {
                maxResponse = Int(mr)
            }
        default:
            throw ResponseStatus.WrongLength
        }
    }

    init(noBody: Bool, maxResponse: Int = MaxResponseSize) {
        self.noBody = noBody
        self.maxResponse = maxResponse
    }

    func debug() {
        print("Command trailer (no body: \(noBody)):")
        print("  Max response len: \(maxResponse)")

    }
}
