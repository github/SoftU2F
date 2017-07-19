//
//  VersionRequestTests.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 2/6/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest

@testable import APDU
class VersionRequestTests: XCTestCase {
    func testChromeRequest() throws {
        let r = Data(base64Encoded: "AAMAAAAAAA==")!
        let c = try VersionRequest(raw: r)
        
        XCTAssertEqual(c.header.cla, CommandClass.Reserved)
        XCTAssertEqual(c.header.ins, CommandCode.Version)
        XCTAssertEqual(c.header.p1, 0x00)
        XCTAssertEqual(c.header.p2, 0x00)
        XCTAssertEqual(c.header.dataLength, 0)
        XCTAssertEqual(c.body.count, 0)
        XCTAssertEqual(c.trailer.maxResponse, MaxResponseSize)
        XCTAssertEqual(c.raw, r)
    }
    
    func testRequest() {
        let c = VersionRequest()

        XCTAssertEqual(c.header.cla, CommandClass.Reserved)
        XCTAssertEqual(c.header.ins, CommandCode.Version)
        XCTAssertEqual(c.header.p1, 0x00)
        XCTAssertEqual(c.header.p2, 0x00)
        XCTAssertEqual(c.header.dataLength, 0)
        XCTAssertEqual(c.body.count, 0)
        XCTAssertEqual(c.trailer.maxResponse, MaxResponseSize)
        XCTAssertEqual(c.raw, Data(bytes: [0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00]))
    }
}
