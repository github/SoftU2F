//
//  RegisterRequest.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/10/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

struct RegisterRequest: APDUCommandDataProtocol {
    static let cmdClass = APDUCommandHeader.CommandClass.Reserved
    static let cmdCode  = APDUCommandHeader.CommandCode.Register

    let challengeParameter: Data
    let applicationParameter: Data

    var raw: Data {
        let writer = DataWriter()
        writer.writeData(challengeParameter)
        writer.writeData(applicationParameter)
        return writer.buffer
    }

    init(challengeParameter c: Data, applicationParameter a: Data) {
        challengeParameter = c
        applicationParameter = a
    }
    
    init(raw: Data) throws {
        let reader = DataReader(data: raw)
        
        do {
            challengeParameter = try reader.readData(U2F_CHAL_SIZE)
            applicationParameter = try reader.readData(U2F_APPID_SIZE)
        } catch DataReaderError.End {
            throw APDUError.BadSize
        }
    }

    func debug() {
        print("RegisterRequest:")
        print("  Challenge parameter:   \(challengeParameter.base64EncodedString())")
        print("  Application parameter: \(applicationParameter.base64EncodedString())")
    }
}
