//
//  VersionResponse.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/25/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

struct VersionResponse: APDUResponseDataProtocol {
    static let status = APDUResponseTrailer.Status.NoError

    let version:String

    var raw: Data {
        return version.data(using: String.Encoding.utf8)!
    }

    init(version v:String) {
        version = v
    }

    init(raw: Data) throws {
        if let v = String(data: raw, encoding: String.Encoding.utf8) {
            version = v
        } else {
            throw APDUError.BadEncoding
        }
    }
}
