//
//  EndianProtocol.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/12/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

enum Endian {
    case Big
    case Little
}

protocol EndianProtocol {
    init()
    init(littleEndian value: Self)
    init(bigEndian value: Self)

    var bigEndian: Self { get }
    var littleEndian: Self { get }
}

extension UInt64: EndianProtocol { }
extension UInt32: EndianProtocol { }
extension UInt16: EndianProtocol { }
extension UInt8: EndianProtocol {
    init(littleEndian value: UInt8) {
        self = value
    }

    init(bigEndian value: UInt8) {
        self = value
    }

    var bigEndian: UInt8 { return self }
    var littleEndian: UInt8 { return self }
}

protocol EndianEnumProtocol: RawRepresentable {
    associatedtype RawValue: EndianProtocol
}
