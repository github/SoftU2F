//
//  VersionRequest.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/25/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

struct VersionRequest: APDUCommandDataProtocol {
    static let cmdClass = APDUCommandHeader.CommandClass.Reserved
    static let cmdCode = APDUCommandHeader.CommandCode.Version

    var raw: Data {
        return Data(capacity: 0)
    }

    init() {
    }

    init(raw: Data) throws {
    }

    func debug() {
        print("Version Request (no data)")
    }
}
