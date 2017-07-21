//
//  RawConvertible.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 2/7/17.
//

import Foundation

public protocol RawConvertible {
    var raw: Data { get }

    init(raw: Data) throws
}
