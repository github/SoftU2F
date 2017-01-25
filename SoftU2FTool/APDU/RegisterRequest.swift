//
//  RegisterRequest.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/10/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import Foundation

struct RegisterRequest: APDUCommandDataProtocol {
    static let cmdClass = APDUHeader.CommandClass.Reserved
    static let cmdCode  = APDUHeader.CommandCode.Register

    let challengeParameter: Data
    let applicationParameter: Data
    
    init(challengeParameter c: Data, applicationParameter a: Data) {
        challengeParameter = c
        applicationParameter = a
    }
    
    init(raw: Data) throws {
        let reader = DataReader(data: raw)
        
        do {
            challengeParameter = try reader.readData(U2F_CHAL_SIZE)
            applicationParameter = try reader.readData(U2F_APPID_SIZE)
        } catch DataReader.DRError.End {
            throw APDUError.BadSize
        }

        if reader.remaining > 0 { throw APDUError.BadSize }
    }
    
    var raw: Data {
        let writer = DataWriter()
        writer.writeData(challengeParameter)
        writer.writeData(applicationParameter)
        return writer.buffer
    }
}
