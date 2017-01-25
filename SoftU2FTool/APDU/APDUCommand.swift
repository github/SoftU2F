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
    let data: DataType
    
    init(data d: DataType) throws {
        header = try APDUHeader(cmdData: d)
        data = d
    }
    
    init(raw: Data) throws {
        header = try APDUHeader(raw: raw)
        
        guard let cmdType = APDUCommand.commandTypeForCode(header.ins) else { throw APDUError.BadCode }
        
        let dOffset = header.raw.count
        let dData = raw.subdata(in: dOffset..<raw.count)

        data = try cmdType.init(raw: dData)
    }
    
    var raw: Data {
        let writer = DataWriter()
        writer.writeData(header.raw)
        writer.writeData(data.raw)
        return writer.buffer
    }
    
    var registerRequest:       RegisterRequest?       { return data as? RegisterRequest }
    var authenticationRequest: AuthenticationRequest? { return data as? AuthenticationRequest }
    
    static func commandTypeForCode(_ code: APDUHeader.CommandCode) -> DataType.Type? {
        return APDUCommandTypes.lazy.filter({ $0.cmdCode == code }).first
    }
}
