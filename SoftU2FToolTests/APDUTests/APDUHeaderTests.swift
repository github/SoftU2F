//
//  APDUHeaderTests.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import XCTest

class APDUHeaderTests: XCTestCase {
    func testRoundTrip() throws {
        let c = try SHA256.digest("world".data(using: String.Encoding.utf8)!)
        let a = try SHA256.digest("hello".data(using: String.Encoding.utf8)!)
        let cmd = RegisterRequest(challengeParameter: c, applicationParameter: a)
        
        let h1 = try APDUHeader(cmdData: cmd)
        let h2 = try APDUHeader(raw: h1.raw)
        
        XCTAssertEqual(h1.cla, h2.cla)
        XCTAssertEqual(h1.ins, h2.ins)
        XCTAssertEqual(h1.p1, h2.p1)
        XCTAssertEqual(h1.p2, h2.p2)
        XCTAssertEqual(h1.dataLength, h2.dataLength)
    }
}
