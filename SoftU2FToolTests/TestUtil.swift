//
//  Util.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/10/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import Foundation

func tupleDigestEqual(_ a: SHA256.TupleDigest, _ b: SHA256.TupleDigest) -> Bool {
    return
        a.0 == b.0 &&
        a.1 == b.1 &&
        a.2 == b.2 &&
        a.3 == b.3 &&
        a.4 == b.4 &&
        a.5 == b.5 &&
        a.6 == b.6 &&
        a.7 == b.7 &&
        a.8 == b.8 &&
        a.9 == b.9 &&
        a.10 == b.10 &&
        a.11 == b.11 &&
        a.12 == b.12 &&
        a.13 == b.13 &&
        a.14 == b.14 &&
        a.15 == b.15 &&
        a.16 == b.16 &&
        a.17 == b.17 &&
        a.18 == b.18 &&
        a.19 == b.19 &&
        a.20 == b.20 &&
        a.21 == b.21 &&
        a.22 == b.22 &&
        a.23 == b.23 &&
        a.24 == b.24 &&
        a.25 == b.25 &&
        a.26 == b.26 &&
        a.27 == b.27 &&
        a.28 == b.28 &&
        a.29 == b.29 &&
        a.30 == b.30 &&
        a.31 == b.31
}

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

//extension Data {
//    convenience init(chars: [UInt8]) {
//        var vChars = chars
//        self.init(bytes: &vChars, length: vChars.count)
//    }
//}
