//
//  UtilsTests.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 2/1/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest
@testable import SoftU2F

class UtilsTests: XCTestCase {
    func testPadUnpadKeyHandle() {
        let kh = Data(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x06, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14])

        let padded = padKeyHandle(kh)
        XCTAssertEqual(padded.count, kh.count + 50)

        let unpadded = unpadKeyHandle(padded)
        XCTAssertEqual(unpadded, kh)
    }

    func testUnpadBadKeyHandle() {
        let bad = Data(bytes: [0xde, 0xad, 0xbe, 0xef]) // to small to be paadded.
        let unpadded = unpadKeyHandle(bad)
        XCTAssertEqual(unpadded, bad)
    }
}
