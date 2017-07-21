//
//  Command.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 2/7/17.
//

import Foundation

public func commandType(raw: Data) throws -> CommandCode {
    let reader = DataReader(data: raw)
    let header = try CommandHeader(reader: reader)
    return header.ins
}

public protocol Command {
    var header: CommandHeader { get }
    var body: Data { get }
    var trailer: CommandTrailer { get }

    init(header: CommandHeader, body: Data, trailer: CommandTrailer)

    func validateBody() throws
}

// Implement RawConvertible
extension Command {
    public var raw: Data {
        let writer = DataWriter()
        writer.writeData(header.raw)
        writer.writeData(body)
        writer.writeData(trailer.raw)

        return writer.buffer
    }

    public init(raw: Data) throws {
        let reader = DataReader(data: raw)
        let header: CommandHeader
        let body: Data
        let trailer: CommandTrailer

        do {
            header = try CommandHeader(reader: reader)
            body = try reader.readData(header.dataLength)
            trailer = try CommandTrailer(reader: reader)
        } catch DataReaderError.End {
            throw ResponseStatus.WrongLength
        }

        self.init(header: header, body: body, trailer: trailer)

        try validateBody()
    }
}
