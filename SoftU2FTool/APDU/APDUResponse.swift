//
//  APDUResponse.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/12/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import Foundation

struct APDUResponse<ResponseType:APDUResponseDataProtocol>: APDUMessageProtocol {
    typealias DataType = APDUResponseDataProtocol
    
    let data: ResponseType
    let trailer: APDUTrailer
    
    var raw: NSData {
        let writer = DataWriter()
        writer.writeData(data.raw)
        writer.writeData(trailer.raw)
        return writer.buffer
    }
    
    init(data d: ResponseType) {
        data = d
        trailer = APDUTrailer(data: data)
    }
    
    init(raw: NSData) throws {
        let reader = DataReader(data: raw)
        
        let dData = try reader.readData(reader.remaining - 2)
        data = try ResponseType(raw: dData)
        trailer = try APDUTrailer(raw: reader.rest)
    }
}