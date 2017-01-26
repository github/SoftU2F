//
//  ErrorResponse.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/26/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

struct ErrorResponse: APDUMessageProtocol {
    let status: APDUResponseStatus

    var raw: Data {
        let writer = DataWriter()

        writer.write(status)

        return writer.buffer
    }

    init(status s: APDUResponseStatus) {
        status = s
    }

    init(raw: Data) throws {
        let reader = DataReader(data: raw)
        status = try reader.read()

        if reader.remaining > 0 {
            throw APDUError.BadSize
        }
    }

    func debug() {
        print("Error Response:")
        print("  Status: \(status)")
    }
}
