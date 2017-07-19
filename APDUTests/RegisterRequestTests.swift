//
//  RegisterRequestTests.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 2/6/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest
@testable import APDU

class RegisterRequestTests: XCTestCase {
    func testChromeRequest() throws {
        let r = Data(base64Encoded: "AAEDAAAAQEr8hj61EL83BjxGaqSnMUyWyXeBIAhGhQ2zbkFcgOzbcGF9/tBlhjr0fBVVbJF5iICCjMQH/fcK6FARVpRloHUAAA==")!
        let c = try RegisterRequest(raw: r)
        
        XCTAssertEqual(c.header.cla, CommandClass.Reserved)
        XCTAssertEqual(c.header.ins, CommandCode.Register)
        XCTAssertEqual(c.header.p1, Control.EnforceUserPresenceAndSign.rawValue)
        XCTAssertEqual(c.header.p2, 0x00)
        XCTAssertEqual(c.trailer.maxResponse, MaxResponseSize)
        XCTAssertEqual(c.raw, r)
    }
    
    func testRequest() throws {
        let c = Data(repeating: 0xAA, count: 32)
        let a = Data(repeating: 0xBB, count: 32)
        let cmd = RegisterRequest(challengeParameter: c, applicationParameter: a)

        XCTAssertEqual(cmd.header.cla, CommandClass.Reserved)
        XCTAssertEqual(cmd.header.ins, CommandCode.Register)
        XCTAssertEqual(cmd.header.p1, 0x00)
        XCTAssertEqual(cmd.header.p2, 0x00)
        XCTAssertEqual(cmd.challengeParameter, c)
        XCTAssertEqual(cmd.applicationParameter, a)
        XCTAssertEqual(cmd.trailer.maxResponse, MaxResponseSize)
        XCTAssertEqual(cmd.raw, Data(bytes: [
            0x00,
            0x01,
            0x00,
            0x00,
            0x00,
            0x00,
            0x40,
            0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,
            0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB,
            0x00,
            0x00
        ]))
        
        let cmd2 = try RegisterRequest(raw: cmd.raw)
        XCTAssertEqual(cmd.header.cla, cmd2.header.cla)
        XCTAssertEqual(cmd.header.ins, cmd2.header.ins)
        XCTAssertEqual(cmd.header.p1, cmd2.header.p1)
        XCTAssertEqual(cmd.header.p2, cmd2.header.p2)
        XCTAssertEqual(cmd.challengeParameter, cmd2.challengeParameter)
        XCTAssertEqual(cmd.applicationParameter, cmd2.applicationParameter)
        XCTAssertEqual(cmd.trailer.maxResponse, cmd2.trailer.maxResponse)
    }
}
