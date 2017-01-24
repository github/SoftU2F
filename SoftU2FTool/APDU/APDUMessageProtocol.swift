//
//  APDUMessage.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/12/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import Foundation

protocol APDUMessageProtocol {
    var raw: NSData { get }
    init(raw: NSData) throws
}