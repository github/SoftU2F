//
//  RegisterResponse.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation
import SelfSignedCertificate

public struct RegisterResponse: MessageProtocol {
    // Parse a DER formatted X509 certificate from the beginning of a datum and return its length.
    static func certLength(fromData d: Data) throws -> Int {
        var size: Int = 0
        if SelfSignedCertificate.parseX509(d, consumed: &size) {
            return size
        } else {
            throw ResponseStatus.OtherError
        }
    }

    public let publicKey: Data
    public let keyHandle: Data
    public let certificate: Data
    public let signature: Data
    public let status: ResponseStatus

    public var raw: Data {
        let writer = DataWriter()

        writer.write(UInt8(0x05))
        writer.writeData(publicKey)
        writer.write(UInt8(keyHandle.count))
        writer.writeData(keyHandle)
        writer.writeData(certificate)
        writer.writeData(signature)
        writer.write(status)

        return writer.buffer
    }

    public init(raw: Data) throws {
        let reader = DataReader(data: raw)

        do {
            // reserved byte
            let _: UInt8 = try reader.read()

            publicKey = try reader.readData(U2F_EC_POINT_SIZE)

            let khLen: UInt8 = try reader.read()
            keyHandle = try reader.readData(Int(khLen))

            // peek at cert to figure out its length
            let certLen = try RegisterResponse.certLength(fromData: reader.rest)
            certificate = try reader.readData(certLen)

            signature = try reader.readData(reader.remaining - 2)

            status = try reader.read()
        } catch DataReaderError.End {
            throw ResponseStatus.WrongLength
        }

        if reader.remaining > 0 {
            throw ResponseStatus.WrongLength
        }
    }

    public init(publicKey pk: Data, keyHandle kh: Data, certificate cert: Data, signature sig: Data) {
        publicKey = pk
        keyHandle = kh
        certificate = cert
        signature = sig
        status = .NoError
    }

    public func debug() {
        print("Registration Response:")
        print( "  Reserved:    0x05")
        print( "  Public key:  \(publicKey.base64EncodedString())")
        print(String(format: "  KH Len:      0x%02x", keyHandle.count))
        print( "  Key Handle:  \(keyHandle.base64EncodedString())")
        print( "  Certificate: \(certificate.base64EncodedString())")
        print( "  Signature:   \(signature.base64EncodedString())")
        print( "  Status:      \(status)")
    }
}
