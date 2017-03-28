//
//  AuthenticationRequest.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/14/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

public struct AuthenticationRequest: RawConvertible {
    public let header: CommandHeader
    public let body: Data
    public let trailer: CommandTrailer
    
    public var control: Control {
        return Control(rawValue: header.p1) ?? .Invalid
    }

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
    
    var keyHandleLength: Int {
        return Int(body[U2F_CHAL_SIZE + U2F_APPID_SIZE])
    }

    public var keyHandle: Data {
        let lowerBound = U2F_CHAL_SIZE + U2F_APPID_SIZE + 1
        let upperBound = lowerBound + keyHandleLength
        return body.subdata(in: lowerBound..<upperBound)
    }

    public init(challengeParameter: Data, applicationParameter: Data, keyHandle: Data, control: Control) {
        let writer = DataWriter()
        writer.writeData(challengeParameter)
        writer.writeData(applicationParameter)
        writer.write(UInt8(keyHandle.count))
        writer.writeData(keyHandle)
        
        self.body = writer.buffer
        self.header = CommandHeader(ins: .Authenticate, p1: control.rawValue, dataLength: body.count)
        self.trailer = CommandTrailer(noBody: false)
    }
}

extension AuthenticationRequest: Command {
    public init(header: CommandHeader, body: Data, trailer: CommandTrailer) {
        self.header = header
        self.body = body
        self.trailer = trailer
    }
    
    public func validateBody() throws {
        // Make sure it's at least long enough to have key-handle length.
        if body.count < U2F_CHAL_SIZE + U2F_APPID_SIZE + 1 {
            throw ResponseStatus.WrongLength
        }
        
        if body.count != U2F_CHAL_SIZE + U2F_APPID_SIZE + 1 + keyHandleLength {
            throw ResponseStatus.WrongLength
        }
        
        if control == .Invalid {
            throw ResponseStatus.OtherError
        }
    }
}
