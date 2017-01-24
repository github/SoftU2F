//
//  APDUCommand.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import Foundation

let APDUCommandTypes:[APDUCommandDataProtocol.Type] = [
    RegisterRequest.self,
    AuthenticationRequest.self
]

struct APDUCommand: APDUMessageProtocol {
    typealias DataType = APDUCommandDataProtocol
    
    let header: APDUHeader
    let data: APDUCommandDataProtocol
    
    init(data d: APDUCommandDataProtocol) throws {
        header = try APDUHeader(cmdData: d)
        data = d
    }
    
    init(raw: NSData) throws {
        header = try APDUHeader(raw: raw)
        
        guard let cmdType = APDUCommand.commandTypeForCode(header.ins) else { throw APDUError.BadCode }
        
        let dOffset = header.raw.length
        let dRange = NSMakeRange(dOffset, raw.length - dOffset)
        let dData = raw.subdataWithRange(dRange)

        data = try cmdType.init(raw: dData)
    }
    
    var raw: NSData {
        let writer = DataWriter()
        writer.writeData(header.raw)
        writer.writeData(data.raw)
        return writer.buffer
    }
    
    var registerRequest:       RegisterRequest?       { return data as? RegisterRequest }
    var authenticationRequest: AuthenticationRequest? { return data as? AuthenticationRequest }
    
    static func commandTypeForCode(code: APDUHeader.CommandCode) -> APDUCommandDataProtocol.Type? {
        return APDUCommandTypes.lazy.filter({ $0.cmdCode == code }).first
    }
}
