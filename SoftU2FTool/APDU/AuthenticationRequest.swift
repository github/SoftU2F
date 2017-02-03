//
//  AuthenticationRequest.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/14/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

struct AuthenticationRequest: APDUCommandDataProtocol {
    enum Control: UInt8 {
        case EnforceUserPresenceAndSign = 0x03
        case CheckOnly = 0x07
    }

    static let cmdClass = APDUCommandHeader.CommandClass.Reserved
    static let cmdCode = APDUCommandHeader.CommandCode.Authenticate

    let challengeParameter: Data
    let applicationParameter: Data
    let keyHandle: Data

    var raw: Data {
        let writer = DataWriter()

        writer.writeData(challengeParameter)
        writer.writeData(applicationParameter)
        writer.write(UInt8(keyHandle.count))
        writer.writeData(keyHandle)

        return writer.buffer
    }

    init(challengeParameter cp: Data, applicationParameter ap: Data, keyHandle kh: Data) {
        challengeParameter = cp
        applicationParameter = ap
        keyHandle = kh
    }

    init(raw: Data) throws {
        let reader = DataReader(data: raw)

        do {
            challengeParameter = try reader.readData(U2F_CHAL_SIZE)
            applicationParameter = try reader.readData(U2F_APPID_SIZE)
            let khLen: UInt8 = try reader.read()
            keyHandle = try reader.readData(khLen)
        } catch DataReaderError.End {
            throw APDUError.BadSize
        }
    }

    func debug() {
        print("AuthenticationRequest:")
        print("  Challenge parameter:   \(challengeParameter.base64EncodedString())")
        print("  Application parameter: \(applicationParameter.base64EncodedString())")
        print("  Key handle:            \(keyHandle.base64EncodedString())")
    }
}
