//
//  RegisterRequest.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/10/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

public struct RegisterRequest: CommandDataProtocol {
    public static let cmdClass = CommandClass.Reserved
    public static let cmdCode = CommandCode.Register

    public let challengeParameter: Data
    public let applicationParameter: Data

    public var raw: Data {
        let writer = DataWriter()
        writer.writeData(challengeParameter)
        writer.writeData(applicationParameter)
        return writer.buffer
    }

    public init(challengeParameter c: Data, applicationParameter a: Data) {
        challengeParameter = c
        applicationParameter = a
    }

    public init(raw: Data) throws {
        let reader = DataReader(data: raw)

        do {
            challengeParameter = try reader.readData(U2F_CHAL_SIZE)
            applicationParameter = try reader.readData(U2F_APPID_SIZE)
        } catch DataReaderError.End {
            throw ResponseStatus.WrongLength
        }
    }

    public func debug() {
        print("RegisterRequest:")
        print("  Challenge parameter:   \(challengeParameter.base64EncodedString())")
        print("  Application parameter: \(applicationParameter.base64EncodedString())")
    }
}
