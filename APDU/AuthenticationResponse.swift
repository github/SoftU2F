//
//  AuthenticationResponse.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 9/14/16.
//

import Foundation

public struct AuthenticationResponse: RawConvertible {
    let body: Data
    let trailer: ResponseStatus

    public var userPresence: UInt8 {
        return body[0]
    }

    public var counter: UInt32 {
        let lowerBound = MemoryLayout<UInt8>.size
        let upperBound = lowerBound + MemoryLayout<UInt32>.size
        let data = body.subdata(in: lowerBound..<upperBound)

        return data.withUnsafeBytes { (ptr: UnsafePointer<UInt32>) -> UInt32 in
            return ptr.pointee.bigEndian
        }
    }

    public var signature: Data {
        let lowerBound = MemoryLayout<UInt8>.size + MemoryLayout<UInt32>.size
        let upperBound = body.count
        return body.subdata(in: lowerBound..<upperBound)
    }

    public init(userPresence: UInt8, counter: UInt32, signature: Data) {
        let writer = DataWriter()
        writer.write(userPresence)
        writer.write(counter)
        writer.writeData(signature)

        body = writer.buffer
        trailer = .NoError
    }
}

extension AuthenticationResponse: Response {
    init(body: Data, trailer: ResponseStatus) {
        self.body = body
        self.trailer = trailer
    }

    func validateBody() throws {
        // TODO: minimum signature size?
        if body.count < MemoryLayout<UInt8>.size + MemoryLayout<UInt32>.size + 1 {
            throw ResponseError.BadSize
        }

        if trailer != .NoError {
            throw ResponseError.BadStatus
        }
    }
}
