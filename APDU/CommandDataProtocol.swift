//
//  CommandDataProtocol.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/12/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

public protocol CommandDataProtocol {
    static var cmdClass: CommandClass { get }
    static var cmdCode: CommandCode { get }

    var raw: Data { get }
    init(raw: Data) throws

    func debug()
}

extension CommandDataProtocol {
    // Register request wrapped in an APDU packet.
    func apduWrapped() throws -> MessageProtocol {
        return try Command(data: self)
    }
}
