//
//  VersionRequest.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/25/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

public struct VersionRequest: RawConvertible {
    let header: CommandHeader
    let body: Data
    let trailer: CommandTrailer
    
    func validateBody() throws {
        if body.count > 0 {
            throw ResponseStatus.WrongLength
        }
    }
    
    init() {
        self.header = CommandHeader(ins: .Version, dataLength: 0)
        self.body = Data()
        self.trailer = CommandTrailer(noBody: true)
    }
}

extension VersionRequest: CommandProtocol {
    init(header: CommandHeader, body: Data, trailer: CommandTrailer) {
        self.header = header
        self.body = body
        self.trailer = trailer
    }
}
