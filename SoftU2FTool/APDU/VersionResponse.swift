//
//  VersionResponse.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/25/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

struct VersionResponse: APDUMessageProtocol {
    let version:String
    let status:APDUResponseStatus

    var raw: Data {
        let writer = DataWriter()

        writer.writeData(version.data(using: String.Encoding.utf8)!)
        writer.write(status)

        return writer.buffer
    }

    init(version v:String) {
        version = v
        status = .NoError
    }

    init(raw: Data) throws {
        let reader = DataReader(data: raw)

        let vData = try reader.readData(reader.remaining - 2)
        if let v = String(data: vData, encoding: String.Encoding.utf8) {
            version = v
        } else {
            throw APDUError.BadEncoding
        }

        status = try reader.read()

        if reader.remaining > 0 {
            throw APDUError.BadSize
        }
    }
}
