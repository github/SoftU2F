//
//  ErrorResponse.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/26/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

public struct ErrorResponse: RawConvertible {
    let body: Data
    let trailer: ResponseStatus

    public init(status s: ResponseStatus) {
        body = Data()
        trailer = s
    }
}

extension ErrorResponse: Response {
    init(body: Data, trailer: ResponseStatus) {
        self.body = body
        self.trailer = trailer
    }
    
    func validateBody() throws {
        if body.count != 0 {
            throw ResponseError.BadSize
        }
    }
}
