//
//  ErrorResponse.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/26/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

public struct ErrorResponse: MessageProtocol {
    public let status: ResponseStatus

    public var raw: Data {
        let writer = DataWriter()

        writer.write(status)

        return writer.buffer
    }

    public init(status s: ResponseStatus) {
        status = s
    }

    public init(raw: Data) throws {
        let reader = DataReader(data: raw)
        status = try reader.read()

        if reader.remaining > 0 {
            throw ResponseStatus.WrongLength
        }
    }

    public func debug() {
        print("Error Response:")
        print("  Status: \(status)")
    }
}
