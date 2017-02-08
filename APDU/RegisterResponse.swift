//
//  RegisterResponse.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation
import SelfSignedCertificate

public struct RegisterResponse: RawConvertible {
    let body: Data
    let trailer: ResponseStatus

    var reserved: UInt8 {
        return body.subdata(in: reservedRange)[0]
    }
    
    public var publicKey: Data {
        return body.subdata(in: publicKeyRange)
    }
    
    var keyHandleLength: Int {
        return Int(body.subdata(in: keyHandleLengthRange)[0])
    }

    public var keyHandle: Data {
        return body.subdata(in: keyHandleRange)
    }
    
    public var certificate: Data {
        return body.subdata(in: certificateRange)
    }

    public var signature: Data {
        return body.subdata(in: signatureRange)
    }

    var reservedRange: Range<Int> {
        let lowerBound = 0
        let upperBound = MemoryLayout<UInt8>.size
        return lowerBound..<upperBound
    }
    
    var publicKeyRange: Range<Int> {
        let lowerBound = reservedRange.upperBound
        let upperBound = lowerBound + U2F_EC_POINT_SIZE
        return lowerBound..<upperBound
    }
    
    var keyHandleLengthRange: Range<Int> {
        let lowerBound = publicKeyRange.upperBound
        let upperBound = lowerBound + MemoryLayout<UInt8>.size
        return lowerBound..<upperBound
    }

    var keyHandleRange: Range<Int> {
        let lowerBound = keyHandleLengthRange.upperBound
        let upperBound = lowerBound + keyHandleLength
        return lowerBound..<upperBound
    }
    
    var certificateSize: Int {
        let remainingRange: Range<Int> = keyHandleRange.upperBound..<body.count
        let remaining = body.subdata(in: remainingRange)
        var size: Int = 0

        if SelfSignedCertificate.parseX509(remaining, consumed: &size) {
            return size
        } else {
            return 0
        }
    }
    
    var certificateRange: Range<Int> {
        let lowerBound = keyHandleRange.upperBound
        let upperBound = lowerBound + certificateSize
        return lowerBound..<upperBound
    }
    
    var signatureRange: Range<Int> {
        let lowerBound = certificateRange.upperBound
        let upperBound = body.count
        return lowerBound..<upperBound
    }
    
    public init(publicKey: Data, keyHandle: Data, certificate: Data, signature: Data) {
        let writer = DataWriter()
        writer.write(UInt8(0x05)) // reserved
        writer.writeData(publicKey)
        writer.write(UInt8(keyHandle.count))
        writer.writeData(keyHandle)
        writer.writeData(certificate)
        writer.writeData(signature)

        body = writer.buffer
        trailer = .NoError
    }
}

extension RegisterResponse: Response {
    init(body: Data, trailer: ResponseStatus) {
        self.body = body
        self.trailer = trailer
    }
    
    func validateBody() throws {
        // Check that we at least have key-handle length.
        var min = MemoryLayout<UInt8>.size + U2F_EC_POINT_SIZE + MemoryLayout<UInt8>.size
        if body.count < min {
            throw ResponseError.BadSize
        }

        // Check that we at least have one byte of cert.
        // TODO: minimum cert size?
        min += keyHandleLength + 1
        if body.count < min {
            throw ResponseError.BadSize
        }
        
        // Check that cert is parsable.
        if certificateSize == 0 {
            throw ResponseError.BadCertificate
        }
        
        // Check that we at least have one byte of signature.
        // TODO: minimum signature size?
        min += certificateSize + 1
        if body.count < min {
            throw ResponseError.BadSize
        }

        if reserved != 0x05 {
            throw ResponseError.BadData
        }
        
        if trailer != .NoError {
            throw ResponseError.BadStatus
        }
    }
}
