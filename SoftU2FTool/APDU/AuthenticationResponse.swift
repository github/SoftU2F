//
//  AuthenticationResponse.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/14/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import Foundation

struct AuthenticationResponse: APDUResponseDataProtocol {
    static let status = APDUTrailer.Status.NoError

    let userPresence:UInt8
    let counter:UInt32
    let signature:NSData
    
    var raw: NSData {
        let writer = DataWriter()
        
        writer.write(userPresence)
        writer.write(counter)
        writer.writeData(signature)
        
        return writer.buffer
    }
    
    init(raw: NSData) throws {
        let reader = DataReader(data: raw)
        
        do {
            userPresence = try reader.read()
            counter = try reader.read()
            signature = reader.rest
        } catch DataReader.Error.End {
            throw APDUError.BadSize
        }
    }
    
    init(userPresence u:UInt8, counter c:UInt32, signature s:NSData) {
        userPresence = u
        counter = c
        signature = s
    }
}