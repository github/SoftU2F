//
//  APDUCommand.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

let APDUCommandTypes: [APDUCommandDataProtocol.Type] = [
    RegisterRequest.self,
    AuthenticationRequest.self,
    VersionRequest.self
]

struct APDUCommand: APDUMessageProtocol {
    typealias DataType = APDUCommandDataProtocol

    static func commandTypeForCode(_ code: APDUCommandHeader.CommandCode) -> DataType.Type? {
        return APDUCommandTypes.lazy.filter({ $0.cmdCode == code }).first
    }

    let header: APDUCommandHeader
    let data: DataType
    let trailer: APDUCommandTrailer

    var raw: Data {
        let writer = DataWriter()
        writer.writeData(header.raw)
        writer.writeData(data.raw)
        writer.writeData(trailer.raw)
        return writer.buffer
    }

    var registerRequest: RegisterRequest? { return data as? RegisterRequest }
    var authenticationRequest: AuthenticationRequest? { return data as? AuthenticationRequest }
    var versionRequest: VersionRequest? { return data as? VersionRequest }

    init(data d: DataType) throws {
        header = try APDUCommandHeader(cmdData: d)
        data = d
        trailer = APDUCommandTrailer(cmdData: d)
    }

    init(raw: Data) throws {
        header = try APDUCommandHeader(raw: raw)

        guard let cmdType = APDUCommand.commandTypeForCode(header.ins) else { throw APDUResponseStatus.InsNotSupported }

        var dOffset = header.raw.count
        var dData = raw.subdata(in: dOffset..<raw.count)
        data = try cmdType.init(raw: dData)

        dOffset += data.raw.count
        dData = raw.subdata(in: dOffset..<raw.count)
        trailer = try APDUCommandTrailer(raw: dData)
    }

    func debug() {
        print("APDU Command:")
        header.debug()
        data.debug()
        trailer.debug()
    }
}
