//
//  VersionRequest.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/25/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

public struct VersionRequest: CommandDataProtocol {
    public static let cmdClass = CommandClass.Reserved
    public static let cmdCode = CommandCode.Version

    public var raw: Data {
        return Data(capacity: 0)
    }

    init() {
    }

    public init(raw: Data) throws {
    }

    public func debug() {
        print("Version Request (no data)")
    }
}
