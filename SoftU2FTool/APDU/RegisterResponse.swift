//
//  RegisterResponse.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import Foundation

struct RegisterResponse: APDUResponseDataProtocol {
    static let status = APDUTrailer.Status.NoError
    
    let publicKey:   NSData
    let keyHandle:   NSData
    let certificate: NSData
    let signature:   NSData
    
    init(publicKey pk: NSData, keyHandle kh: NSData, certificate cert: NSData, signature sig: NSData) {
        publicKey = pk
        keyHandle = kh
        certificate = cert
        signature = sig
    }
    
    init(raw: NSData) throws {
        let reader = DataReader(data: raw)
        
        do {
            // reserved byte
            let _:UInt8 = try reader.read()
            
            publicKey = try reader.readData(sizeof(U2F_EC_POINT))
            
            let khLen:UInt8 = try reader.read()
            keyHandle = try reader.readData(Int(khLen))
            
            // peek at cert to figure out its length
            let certLen = try RegisterResponse.certLength(fromData: reader.rest)
            certificate = try reader.readData(certLen)
            
            signature = reader.rest
        } catch DataReader.Error.End {
            throw APDUError.BadSize
        }
    }
    
    var raw: NSData {
        let writer = DataWriter()
        
        writer.write(UInt8(0x05))
        writer.writeData(publicKey)
        writer.write(UInt8(keyHandle.length))
        writer.writeData(keyHandle)
        writer.writeData(certificate)
        writer.writeData(signature)
        
        return writer.buffer
    }
    
    // Parse a DER formatted X509 certificate from the beginning of a datum and return its length.
    static func certLength(fromData d: NSData) throws -> Int {
        var size: Int = 0
        if SelfSignedCertificate.parseX509(d, consumed: &size) == 1 {
            return size
        } else {
            throw APDUError.BadCert
        }
    }
}