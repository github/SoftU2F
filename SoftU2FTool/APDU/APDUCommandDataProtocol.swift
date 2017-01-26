//
//  APDUCommandDataProtocol.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/12/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

protocol APDUCommandDataProtocol {
    static var cmdClass: APDUCommandHeader.CommandClass { get }
    static var cmdCode:  APDUCommandHeader.CommandCode  { get }

    var raw: Data { get }
    init(raw: Data) throws

    func debug()
}

extension APDUCommandDataProtocol {
    // Register request wrapped in an APDU packet.
    func apduWrapped() throws -> APDUMessageProtocol {
        return try APDUCommand(data: self)
    }
}
