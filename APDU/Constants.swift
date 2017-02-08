//
//  Constants.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 2/7/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

let U2F_CHAL_SIZE = 32
let U2F_APPID_SIZE = 32

let U2F_EC_KEY_SIZE = 32                            // EC key size in bytes
let U2F_EC_POINT_SIZE = ((U2F_EC_KEY_SIZE * 2) + 1) // Size of EC point

let MaxResponseSize = Int(UInt16.max) + 1

public enum CommandClass: UInt8 {
    case Reserved = 0x00
}

public enum CommandCode: UInt8 {
    case Register = 0x01
    case Authenticate = 0x02
    case Version = 0x03
    case CheckRegister = 0x04
    case AuthenticateBatch = 0x05
}

public enum Control: UInt8 {
    case EnforceUserPresenceAndSign = 0x03
    case CheckOnly = 0x07
    
    // Used internally.
    case Invalid = 0xFF
}

// ISO7816-4
public enum ResponseStatus: UInt16, EndianEnumProtocol, Error {
    public typealias RawValue = UInt16
    
    case NoError = 0x9000
    case WrongData = 0x6A80
    case ConditionsNotSatisfied = 0x6985
    case CommandNotAllowed = 0x6986
    case InsNotSupported = 0x6D00
    case WrongLength = 0x6700
    case ClassNotSupported = 0x6E00
    case OtherError = 0x6F00 // "No precise diagnosis"
}
