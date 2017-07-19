//
//  CommandHeader.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

public struct CommandHeader: RawConvertible, MessagePart {
    public let cla: CommandClass
    public let ins: CommandCode
    public let p1: UInt8
    public let p2: UInt8
    public let dataLength: Int

    public var raw: Data {
        let writer = DataWriter()

        writer.write(cla.rawValue)
        writer.write(ins.rawValue)
        writer.write(p1)
        writer.write(p2)

        if dataLength > 0 {
            writer.write(UInt8(0x00))
            writer.write(UInt16(dataLength))
        }

        return writer.buffer
    }

    public init(reader: DataReader) throws {
        do {
            let claByte: UInt8 = try reader.read()
            guard let tmpCla = CommandClass(rawValue: claByte) else { throw ResponseStatus.ClassNotSupported }
            cla = tmpCla

            let insByte: UInt8 = try reader.read()
            guard let tmpIns = CommandCode(rawValue: insByte) else { throw ResponseStatus.InsNotSupported }
            ins = tmpIns

            p1 = try reader.read()
            p2 = try reader.read()

            // Only handle long encoding of Lc bytes.

            switch reader.remaining {
            case 0, 1, 2:
                throw ResponseStatus.WrongLength
            case 3:
                // Long encoding: Lc=0 (omitted), Le is prefixed by 0.
                dataLength = 0
            default:
                // Lc is included.
                let lc0: UInt8 = try reader.read()
                if lc0 != 0x00 { throw ResponseStatus.WrongLength }

                let lc: UInt16 = try reader.read()
                dataLength = Int(lc)
            }
        } catch DataReaderError.End {
            throw ResponseStatus.WrongLength
        }
    }
    
    init(cla: CommandClass = .Reserved, ins: CommandCode, p1: UInt8 = 0x00, p2: UInt8 = 0x00, dataLength: Int) {
        self.cla = cla
        self.ins = ins
        self.p1 = p1
        self.p2 = p2
        self.dataLength = dataLength
    }

    func debug() {
        print( "Command Header:")
        print( "  cla:      \(cla)")
        print( "  ins:      \(ins)")
        print(String(format: "  p1:       0x%02d", p1))
        print(String(format: "  p2:       0x%02d", p2))
        print( "  data len: \(dataLength)")
    }
}
