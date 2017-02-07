//
//  CommandTrailerTests.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/25/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest

class CommandTrailerTests: XCTestCase {
    func testNormal() throws {
        let r = Data(bytes: [0x01, 0x02])
        let t = try CommandTrailer(raw: r)

        XCTAssertEqual(t.noBody, false)
        XCTAssertEqual(t.maxResponse, 258)
        XCTAssertEqual(t.raw, r)
    }

    func testNoBody() throws {
        let r = Data(bytes: [0x00, 0x01, 0x02])
        let t = try CommandTrailer(raw: r)

        XCTAssertEqual(t.noBody, true)
        XCTAssertEqual(t.maxResponse, 258)
        XCTAssertEqual(t.raw, r)
    }

    func testMaxResponseLength() throws {
        let r = Data(bytes: [0x00, 0x00])
        let t = try CommandTrailer(raw: r)

        XCTAssertEqual(t.noBody, false)
        XCTAssertEqual(t.maxResponse, 65536)
        XCTAssertEqual(t.raw, r)
    }
}
