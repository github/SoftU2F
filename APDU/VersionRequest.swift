//
//  VersionRequest.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/25/17.
//

import Foundation

public struct VersionRequest: RawConvertible {
    public let header: CommandHeader
    public let body: Data
    public let trailer: CommandTrailer

    init() {
        self.header = CommandHeader(ins: .Version, dataLength: 0)
        self.body = Data()
        self.trailer = CommandTrailer(noBody: true)
    }
}

extension VersionRequest: Command {
    public init(header: CommandHeader, body: Data, trailer: CommandTrailer) {
        self.header = header
        self.body = body
        self.trailer = trailer
    }

    public func validateBody() throws {
        if body.count > 0 {
            throw ResponseStatus.WrongLength
        }
    }
}
