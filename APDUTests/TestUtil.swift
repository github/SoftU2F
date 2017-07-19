//
//  Util.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 9/10/16.
//

import XCTest

func randData(maxLen: Int = 4096) -> Data {
    let dLen = Int(arc4random()) % maxLen
    return randData(length: dLen)
}

func randData(length len: Int) -> Data {
    var d = Data(repeating: 0x00, count: len)

    d.withUnsafeMutableBytes { dPtr in
        arc4random_buf(dPtr, len)
    }

    return d
}
