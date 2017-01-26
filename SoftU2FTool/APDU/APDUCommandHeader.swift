//
//  APDUCommandHeader.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

struct APDUCommandHeader {
    enum CommandClass: UInt8 {
        case Reserved = 0x00
    }
    
    enum CommandCode: UInt8 {
        case Register          = 0x01
        case Authenticate      = 0x02
        case Version           = 0x03
        case CheckRegister     = 0x04
        case AuthenticateBatch = 0x05
    }
    
    let cla: CommandClass
    let ins: CommandCode
    let p1:  UInt8
    let p2:  UInt8
    let dataLength: Int

    var raw: Data {
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
    
    init(cmdData: APDUCommandDataProtocol) throws {
        cla = type(of: cmdData).cmdClass
        ins = type(of: cmdData).cmdCode
        p1 = 0x00
        p2 = 0x00
        dataLength = cmdData.raw.count
        if dataLength > 0xFFFF { throw APDUError.BadSize }
    }
    
    init(raw: Data) throws {
        let reader = DataReader(data: raw)
        
        do {
            let claByte:UInt8 = try reader.read()
            guard let tmpCla = CommandClass(rawValue: claByte) else { throw APDUError.BadClass }
            cla = tmpCla
            
            let insByte:UInt8 = try reader.read()
            guard let tmpIns = CommandCode(rawValue: insByte) else { throw APDUError.BadCode }
            ins = tmpIns
            
            p1 = try reader.read()
            p2 = try reader.read()

            // Only handle long encoding of Lc bytes.

            switch reader.remaining {
            case 0, 1, 2:
                throw APDUError.ShortEncoding
            case 3:
                // Long encoding: Lc=0 (omitted), Le is prefixed by 0.
                dataLength = 0
            default:
                // Lc is included.
                let lc0:UInt8 = try reader.read()
                if lc0 != 0x00 { throw APDUError.ShortEncoding }

                let lc:UInt16 = try reader.read()
                dataLength = Int(lc)
            }
        } catch DataReaderError.End {
            throw APDUError.BadSize
        }
    }
}
