//
//  APDUCommandTests.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest

class APDUCommandTests: XCTestCase {
    func testRegisterRequest() throws {
        let c = Data(repeating: 0xCC, count: 32)
        let a = Data(repeating: 0xAA, count: 32)
        let r = RegisterRequest(challengeParameter: c, applicationParameter: a)

        let cmd1 = try APDUCommand(data: r)
        let cmd2 = try APDUCommand(raw: cmd1.raw)

        XCTAssertEqual(cmd1.header.raw, cmd2.header.raw)
        XCTAssertEqual(cmd1.data.raw, cmd2.data.raw)
        XCTAssertEqual(cmd1.trailer.raw, cmd2.trailer.raw)
    }

    func testVersionRequest() throws {
        // from Chrome
        let r = Data(base64Encoded: "AAMAAAAAAA==")!
        let c = try APDUCommand(raw: r)

        XCTAssertEqual(c.header.cla, APDUCommandHeader.CommandClass.Reserved)
        XCTAssertEqual(c.header.ins, APDUCommandHeader.CommandCode.Version)
        XCTAssertEqual(c.header.p1, 0x00)
        XCTAssertEqual(c.header.p2, 0x00)
        XCTAssertEqual(c.header.dataLength, 0)
        XCTAssertEqual(c.data.raw.count, 0)
        XCTAssertEqual(c.trailer.maxResponse, APDUCommandTrailer.MaxMaxResponse)
        XCTAssertEqual(c.trailer.noBody, true)
        XCTAssertEqual(c.raw, r)
    }

    func testAuthenticationRequest() throws {
        // From Chrome
        let r = Data(base64Encoded: "AAIDAAAAgeOwxEKY/BwUmvv0yJlvuSQnrkHkZJuTTKSVmRt4UrhVcGF9/tBlhjr0fBVVbJF5iICCjMQH/fcK6FARVpRloHVAIA5xiih5UyR97Gx8DMpSZgno9djTV85XM+VQfZNgADuFrTX978Gq3C8F6BfBLgD042ioARsymZUhkDxd3i3nsQAA")!
        let c = try APDUCommand(raw: r)

        XCTAssertEqual(c.header.cla, APDUCommandHeader.CommandClass.Reserved)
        XCTAssertEqual(c.header.ins, APDUCommandHeader.CommandCode.Authenticate)
        XCTAssertEqual(c.header.p1, AuthenticationRequest.Control.EnforceUserPresenceAndSign.rawValue)
        XCTAssertEqual(c.header.p2, 0x00)
    }

    func testCommandTypeForCode() {
        XCTAssert(APDUCommand.commandTypeForCode(.Register)          == RegisterRequest.self)
        XCTAssert(APDUCommand.commandTypeForCode(.Authenticate)      == AuthenticationRequest.self)
        XCTAssert(APDUCommand.commandTypeForCode(.Version)           == VersionRequest.self)
        XCTAssert(APDUCommand.commandTypeForCode(.CheckRegister)     == nil)
        XCTAssert(APDUCommand.commandTypeForCode(.AuthenticateBatch) == nil)
    }
}
