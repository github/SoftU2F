//
//  CommandHeaderTests.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest

class CommandHeaderTests: XCTestCase {
    func testRegisterRequest() throws {
        let c = Data(repeating: 0xCC, count: 32)
        let a = Data(repeating: 0xAA, count: 32)

        let cmd = RegisterRequest(challengeParameter: c, applicationParameter: a)
        let apdu = cmd.raw

        let h = try CommandHeader(raw: apdu)

        XCTAssertEqual(h.cla, CommandClass.Reserved)
        XCTAssertEqual(h.ins, CommandCode.Register)
        XCTAssertEqual(h.p1, 0x00)
        XCTAssertEqual(h.p2, 0x00)
        XCTAssertEqual(h.dataLength, c.count + a.count)
        XCTAssert(apdu.starts(with: h.raw))
    }

    func testVersionRequest() throws {
        let cmd = VersionRequest()
        let apdu = cmd.raw

        let h = try CommandHeader(raw: apdu)

        XCTAssertEqual(h.cla, CommandClass.Reserved)
        XCTAssertEqual(h.ins, CommandCode.Version)
        XCTAssertEqual(h.p1, 0x00)
        XCTAssertEqual(h.p2, 0x00)
        XCTAssertEqual(h.dataLength, 0)
        XCTAssert(apdu.starts(with: h.raw))
    }
}
