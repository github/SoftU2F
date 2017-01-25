//
//  APDUMessageBody.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/12/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import Foundation

protocol APDUMessageDataProtocol {
    var raw: Data { get }
    init(raw: Data) throws
    
    func apduWrapped() throws -> APDUMessageProtocol
    // func bleWrapped()  throws -> BLEMessage
}

protocol APDUCommandDataProtocol: APDUMessageDataProtocol {
    static var cmdClass: APDUHeader.CommandClass { get }
    static var cmdCode:  APDUHeader.CommandCode  { get }
}

extension APDUCommandDataProtocol {
    // Register request wrapped in an APDU packet.
    func apduWrapped() throws -> APDUMessageProtocol {
        return try APDUCommand(data: self)
    }
    
    // Register request wrapped in BLE packets.
    // func bleWrapped()  throws -> BLEMessage {
    //    let apdu = try apduWrapped()
    //    return BLEMessage(command: .Msg, data: apdu.raw)
    // }
}

protocol APDUResponseDataProtocol: APDUMessageDataProtocol {
    static var status: APDUTrailer.Status { get }
}

extension APDUResponseDataProtocol {
    // Register request wrapped in an APDU packet.
    func apduWrapped() throws -> APDUMessageProtocol {
        return APDUResponse(data: self)
    }

    // Register request wrapped in BLE packets.
    // func bleWrapped()  throws -> BLEMessage {
    //   let apdu = try apduWrapped()
    //   return BLEMessage(command: .Msg, data: apdu.raw)
    // }
}
