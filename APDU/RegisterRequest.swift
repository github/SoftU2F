//
//  RegisterRequest.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 9/10/16.
//

import Foundation

public struct RegisterRequest: RawConvertible {
    public let header: CommandHeader
    public let body: Data
    public let trailer: CommandTrailer

    public var challengeParameter: Data {
        let lowerBound = 0
        let upperBound = lowerBound + U2F_CHAL_SIZE
        return body.subdata(in: lowerBound..<upperBound)
    }

    public var applicationParameter: Data {
        let lowerBound = U2F_CHAL_SIZE
        let upperBound = lowerBound + U2F_APPID_SIZE
        return body.subdata(in: lowerBound..<upperBound)
    }

    public init(challengeParameter: Data, applicationParameter: Data) {
        let writer = DataWriter()
        writer.writeData(challengeParameter)
        writer.writeData(applicationParameter)

        self.body = writer.buffer
        self.header = CommandHeader(ins: .Register, dataLength: body.count)
        self.trailer = CommandTrailer(noBody: false)
    }
}

extension RegisterRequest: Command {
    public init(header: CommandHeader, body: Data, trailer: CommandTrailer) {
        self.header = header
        self.body = body
        self.trailer = trailer
    }

    public func validateBody() throws {
        if body.count != U2F_CHAL_SIZE + U2F_APPID_SIZE {
            throw ResponseStatus.WrongLength
        }
    }
}
