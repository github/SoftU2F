//
//  Command.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

let CommandTypes: [CommandDataProtocol.Type] = [
    RegisterRequest.self,
    AuthenticationRequest.self,
    VersionRequest.self
]

public struct Command: MessageProtocol {
    static func commandTypeForCode(_ code: CommandCode) -> CommandDataProtocol.Type? {
        return CommandTypes.lazy.filter({ $0.cmdCode == code }).first
    }

    public let header: CommandHeader
    let data: CommandDataProtocol
    let trailer: CommandTrailer

    public var raw: Data {
        let writer = DataWriter()
        writer.writeData(header.raw)
        writer.writeData(data.raw)
        writer.writeData(trailer.raw)
        return writer.buffer
    }

    public var registerRequest: RegisterRequest? { return data as? RegisterRequest }
    public var authenticationRequest: AuthenticationRequest? { return data as? AuthenticationRequest }
    public var versionRequest: VersionRequest? { return data as? VersionRequest }

    public init(data d: CommandDataProtocol) throws {
        header = try CommandHeader(cmdData: d)
        data = d
        trailer = CommandTrailer(cmdData: d)
    }

    public init(raw: Data) throws {
        header = try CommandHeader(raw: raw)

        guard let cmdType = Command.commandTypeForCode(header.ins) else { throw ResponseStatus.InsNotSupported }

        var dOffset = header.raw.count
        var dData = raw.subdata(in: dOffset..<raw.count)
        data = try cmdType.init(raw: dData)

        dOffset += data.raw.count
        dData = raw.subdata(in: dOffset..<raw.count)
        trailer = try CommandTrailer(raw: dData)
    }

    public func debug() {
        print("APDU Command:")
        header.debug()
        data.debug()
        trailer.debug()
    }
}
