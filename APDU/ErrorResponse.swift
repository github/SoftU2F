//
//  ErrorResponse.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/26/17.
//

import Foundation

public struct ErrorResponse: RawConvertible {
    public let body: Data
    public let trailer: ResponseStatus

    public init(status s: ResponseStatus) {
        body = Data()
        trailer = s
    }
}

extension ErrorResponse: Response {
    public init(body: Data, trailer: ResponseStatus) {
        self.body = body
        self.trailer = trailer
    }

    public func validateBody() throws {
        if body.count != 0 {
            throw ResponseError.BadSize
        }
    }
}
