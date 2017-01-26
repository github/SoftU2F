//
//  AuthenticationResponse.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/14/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

struct AuthenticationResponse: APDUMessageProtocol {
    let userPresence:UInt8
    let counter:UInt32
    let signature:Data
    let status:APDUResponseStatus
    
    var raw: Data {
        let writer = DataWriter()
        
        writer.write(userPresence)
        writer.write(counter)
        writer.writeData(signature)
        writer.write(status)
        
        return writer.buffer
    }
    
    init(raw: Data) throws {
        let reader = DataReader(data: raw)
        
        do {
            userPresence = try reader.read()
            counter = try reader.read()
            signature = try reader.readData(reader.remaining - 2)
            status = try reader.read()
        } catch DataReaderError.End {
            throw APDUError.BadSize
        }

        if reader.remaining > 0 {
            throw APDUError.BadSize
        }
    }

    init(userPresence u:UInt8, counter c:UInt32, signature s:Data) {
        userPresence = u
        counter = c
        signature = s
        status = .NoError
    }

    func debug() {
        print("AuthenticationResponse:")
        print(String(format: "  User presence: 0x%02x", userPresence))
        print(String(format: "  Counter:       0x%08x", counter))
        print(               "  Signature:     \(signature.base64EncodedString())")
        print(               "  Status:        \(status)")
    }
}
