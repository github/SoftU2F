//
//  AuthenticationRequestTests.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 2/6/17.
//  Copyright © 2017 GitHub. All rights reserved.
//
import XCTest

class AuthenticationRequestTests: XCTestCase {
    func testChromeRequest() throws {
        let r = Data(base64Encoded: "AAIDAAAAgeOwxEKY/BwUmvv0yJlvuSQnrkHkZJuTTKSVmRt4UrhVcGF9/tBlhjr0fBVVbJF5iICCjMQH/fcK6FARVpRloHVAIA5xiih5UyR97Gx8DMpSZgno9djTV85XM+VQfZNgADuFrTX978Gq3C8F6BfBLgD042ioARsymZUhkDxd3i3nsQAA")!
        let c = try AuthenticationRequest(raw: r)
        
        XCTAssertEqual(c.header.cla, CommandClass.Reserved)
        XCTAssertEqual(c.header.ins, CommandCode.Authenticate)
        XCTAssertEqual(c.header.p1, Control.EnforceUserPresenceAndSign.rawValue)
        XCTAssertEqual(c.header.p2, 0x00)
        XCTAssertEqual(c.trailer.maxResponse, MaxResponseSize)
        XCTAssertEqual(c.raw, r)
    }
    
    func testRequest() throws {
        let c = Data(repeating: 0xAA, count: 32)
        let a = Data(repeating: 0xBB, count: 32)
        let k = Data(repeating: 0xCC, count: 16)
        let cmd = AuthenticationRequest(challengeParameter: c, applicationParameter: a, keyHandle: k, control: .CheckOnly)
        
        XCTAssertEqual(cmd.header.cla, CommandClass.Reserved)
        XCTAssertEqual(cmd.header.ins, CommandCode.Authenticate)
        XCTAssertEqual(cmd.control, Control.CheckOnly)
        XCTAssertEqual(cmd.header.p2, 0x00)
        XCTAssertEqual(cmd.challengeParameter, c)
        XCTAssertEqual(cmd.applicationParameter, a)
        XCTAssertEqual(cmd.keyHandle, k)
        XCTAssertEqual(cmd.trailer.maxResponse, MaxResponseSize)
        XCTAssertEqual(cmd.raw, Data(bytes: [
            0x00,
            0x02,
            0x07,
            0x00,
            0x00,
            0x00,
            0x51,
            0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA,
            0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB,
            0x10,
            0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC,
            0x00,
            0x00
        ]))
        
        let cmd2 = try AuthenticationRequest(raw: cmd.raw)
        XCTAssertEqual(cmd.header.cla, cmd2.header.cla)
        XCTAssertEqual(cmd.header.ins, cmd2.header.ins)
        XCTAssertEqual(cmd.header.p1, cmd2.header.p1)
        XCTAssertEqual(cmd.header.p2, cmd2.header.p2)
        XCTAssertEqual(cmd.challengeParameter, cmd2.challengeParameter)
        XCTAssertEqual(cmd.applicationParameter, cmd2.applicationParameter)
        XCTAssertEqual(cmd.keyHandle, cmd2.keyHandle)
        XCTAssertEqual(cmd.trailer.maxResponse, cmd2.trailer.maxResponse)
    }
}
