//
//  VersionRequest.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/25/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

struct VersionRequest: APDUCommandDataProtocol {
    static let cmdClass = APDUCommandHeader.CommandClass.Reserved
    static let cmdCode = APDUCommandHeader.CommandCode.Version

    var raw: Data {
        return Data(capacity: 0)
    }

    init() {
    }

    init(raw: Data) throws {
        if raw.count > 0 { throw APDUError.BadSize }
    }
}
