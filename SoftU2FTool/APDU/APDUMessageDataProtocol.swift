//
//  APDUMessageBody.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/12/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

protocol APDUMessageDataProtocol {
    var raw: Data { get }
    init(raw: Data) throws
    
    func apduWrapped() throws -> APDUMessageProtocol
    // func bleWrapped()  throws -> BLEMessage
}

protocol APDUCommandDataProtocol: APDUMessageDataProtocol {
    static var cmdClass: APDUCommandHeader.CommandClass { get }
    static var cmdCode:  APDUCommandHeader.CommandCode  { get }
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
    static var status: APDUResponseTrailer.Status { get }
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
