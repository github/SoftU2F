//
//  APDUTrailer.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/12/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import Foundation

struct APDUTrailer {
    
    // ISO7816-4
    enum Status: UInt16, EndianEnumProtocol {
        typealias RawValue = UInt16
        
        case NoError                = 0x9000
        case WrongData              = 0x6A80
        case ConditionsNotSatisfied = 0x6985
        case CommandNotAllowed      = 0x6986
        case InsNotSupported        = 0x6D00
    }
    
    let status: Status
    
    var raw: NSData {
        return NSData(int: status.rawValue)
    }
    
    init(data: APDUResponseDataProtocol) {
        status = data.dynamicType.status
    }
    
    init(raw: NSData) throws {
        let reader = DataReader(data: raw)
        status = try reader.read()
    }
}