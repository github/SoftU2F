//
//  EndianProtocol.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/12/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

public enum Endian {
    case Big
    case Little
}

public protocol EndianProtocol {
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
    public init(littleEndian value: UInt8) {
        self = value
    }

    public init(bigEndian value: UInt8) {
        self = value
    }

    public var bigEndian: UInt8 { return self }
    public var littleEndian: UInt8 { return self }
}

public protocol EndianEnumProtocol: RawRepresentable {
    associatedtype RawValue: EndianProtocol
}
