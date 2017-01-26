//
//  APDUCommandTrailer.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/25/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

struct APDUCommandTrailer {
    static let MaxMaxResponse = Int(UInt16.max) + 1

    let maxResponse:Int
    let noBody:Bool

    var raw: Data {
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

    init(raw: Data) throws {
        let reader = DataReader(data: raw)

        // 0 is prepended to trailer if there was no body.
        if reader.remaining == 3 {
            noBody = true
            let zero:UInt8 = try reader.read()
            if zero != 0x00 { throw APDUError.BadEncoding }
        } else {
            noBody = false
        }

        switch reader.remaining {
        case 0:
            maxResponse = 0
        case 1:
            throw APDUError.ShortEncoding
        case 2:
            let mr:UInt16 = try reader.read()
            if mr == 0x0000 {
                maxResponse = APDUCommandTrailer.MaxMaxResponse
            } else {
                maxResponse = Int(mr)
            }
        default:
            throw APDUError.BadEncoding
        }
    }

    init(cmdData cd:APDUCommandDataProtocol, maxResponse mr:Int = APDUCommandTrailer.MaxMaxResponse) {
        maxResponse = mr
        noBody = cd.raw.count == 0
    }
}
