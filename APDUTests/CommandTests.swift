//
//  CommandTests.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest

class CommandTests: XCTestCase {
    func testChromeRegisterRequest() throws {
        let r = Data(base64Encoded: "AAEDAAAAQEr8hj61EL83BjxGaqSnMUyWyXeBIAhGhQ2zbkFcgOzbcGF9/tBlhjr0fBVVbJF5iICCjMQH/fcK6FARVpRloHUAAA==")!
        let c = try Command(raw: r)

        XCTAssertEqual(c.header.cla, CommandClass.Reserved)
        XCTAssertEqual(c.header.ins, CommandCode.Register)
        XCTAssertEqual(c.header.p1, Control.EnforceUserPresenceAndSign.rawValue)
        XCTAssertEqual(c.header.p2, 0x00)
        XCTAssertEqual(c.trailer.maxResponse, CommandTrailer.MaxMaxResponse)
        XCTAssertEqual(c.trailer.noBody, false)
        XCTAssertNotNil(c.registerRequest)
        XCTAssertEqual(c.raw, r)
    }

    func testChromeVersionRequest() throws {
        let r = Data(base64Encoded: "AAMAAAAAAA==")!
        let c = try Command(raw: r)

        XCTAssertEqual(c.header.cla, CommandClass.Reserved)
        XCTAssertEqual(c.header.ins, CommandCode.Version)
        XCTAssertEqual(c.header.p1, 0x00)
        XCTAssertEqual(c.header.p2, 0x00)
        XCTAssertEqual(c.header.dataLength, 0)
        XCTAssertEqual(c.data.raw.count, 0)
        XCTAssertEqual(c.trailer.maxResponse, CommandTrailer.MaxMaxResponse)
        XCTAssertEqual(c.trailer.noBody, true)
        XCTAssertNotNil(c.versionRequest)
        XCTAssertEqual(c.raw, r)
    }

    func testChromeAuthenticationRequest() throws {
        let r = Data(base64Encoded: "AAIDAAAAgeOwxEKY/BwUmvv0yJlvuSQnrkHkZJuTTKSVmRt4UrhVcGF9/tBlhjr0fBVVbJF5iICCjMQH/fcK6FARVpRloHVAIA5xiih5UyR97Gx8DMpSZgno9djTV85XM+VQfZNgADuFrTX978Gq3C8F6BfBLgD042ioARsymZUhkDxd3i3nsQAA")!
        let c = try Command(raw: r)

        XCTAssertEqual(c.header.cla, CommandClass.Reserved)
        XCTAssertEqual(c.header.ins, CommandCode.Authenticate)
        XCTAssertEqual(c.header.p1, Control.EnforceUserPresenceAndSign.rawValue)
        XCTAssertEqual(c.header.p2, 0x00)
        XCTAssertEqual(c.trailer.maxResponse, CommandTrailer.MaxMaxResponse)
        XCTAssertEqual(c.trailer.noBody, false)
        XCTAssertNotNil(c.authenticationRequest)
        XCTAssertEqual(c.raw, r)
    }

    func testCommandTypeForCode() {
        XCTAssert(Command.commandTypeForCode(.Register) == RegisterRequest.self)
        XCTAssert(Command.commandTypeForCode(.Authenticate) == AuthenticationRequest.self)
        XCTAssert(Command.commandTypeForCode(.Version) == VersionRequest.self)
        XCTAssert(Command.commandTypeForCode(.CheckRegister) == nil)
        XCTAssert(Command.commandTypeForCode(.AuthenticateBatch) == nil)
    }
}
