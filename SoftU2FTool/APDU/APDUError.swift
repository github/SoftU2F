//
//  APDUError.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

enum APDUError: Error {
    case BadSize
    case BadClass
    case BadCode
    case BadCert
    case BadEncoding
    case ShortEncoding
}
