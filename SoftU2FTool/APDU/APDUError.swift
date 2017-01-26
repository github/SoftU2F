//
//  APDUError.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import Foundation

enum APDUError: Error {
    case BadSize
    case BadClass
    case BadCode
    case BadCert
    case BadEncoding
    case ShortEncoding
}
