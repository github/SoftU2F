//
//  AuthenticationRequest.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/14/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import Foundation

struct AuthenticationRequest: APDUCommandDataProtocol {
    enum Control: UInt8, EndianEnumProtocol {
        typealias RawValue = UInt8

        case EnforceUserPresenceAndSign = 0x03
        case CheckOnly                  = 0x07
    }
    
    static let cmdClass = APDUHeader.CommandClass.Reserved
    static let cmdCode = APDUHeader.CommandCode.Authenticate
    
    let control: Control
    let challengeParameter: NSData
    let applicationParameter: NSData
    let keyHandle: NSData
    
    var raw: NSData {
        let writer = DataWriter()
        
        writer.write(control.rawValue)
        writer.writeData(challengeParameter)
        writer.writeData(applicationParameter)
        writer.write(UInt8(keyHandle.length))
        writer.writeData(keyHandle)
        
        return writer.buffer
    }
    
    init(control c: Control, challengeParameter cp: NSData, applicationParameter ap: NSData, keyHandle kh: NSData) {
        control = c
        challengeParameter = cp
        applicationParameter = ap
        keyHandle = kh
    }
    
    init(raw: NSData) throws {
        let reader = DataReader(data: raw)
        
        do {
            control = try reader.read()
            challengeParameter = try reader.readData(U2F_CHAL_SIZE)
            applicationParameter = try reader.readData(U2F_APPID_SIZE)
            let khLen:UInt8 = try reader.read()
            keyHandle = try reader.readData(khLen)
        } catch DataReader.Error.End {
            throw APDUError.BadSize
        }
        
        if reader.remaining > 0 { throw APDUError.BadSize }
    }
}