//
//  APDUResponseStatus.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/26/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

// ISO7816-4
enum APDUResponseStatus: UInt16, EndianEnumProtocol {
    typealias RawValue = UInt16

    case NoError                = 0x9000
    case WrongData              = 0x6A80
    case ConditionsNotSatisfied = 0x6985
    case CommandNotAllowed      = 0x6986
    case InsNotSupported        = 0x6D00
    case OtherError             = 0x6F00 // "No precise diagnosis"
}
