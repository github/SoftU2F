//
//  APDUCommandTests.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import XCTest

class APDUCommandTests: XCTestCase {
    func testRoundTrip() throws {
        let c = Data(repeating: 0xCC, count: 32)
        let a = Data(repeating: 0xAA, count: 32)
        let r = RegisterRequest(challengeParameter: c, applicationParameter: a)

        let cmd1 = try APDUCommand(data: r)
        let cmd2 = try APDUCommand(raw: cmd1.raw)

        XCTAssertEqual(cmd1.header.raw, cmd2.header.raw)
        XCTAssertEqual(cmd1.data.raw, cmd2.data.raw)
        XCTAssertEqual(cmd1.trailer.raw, cmd2.trailer.raw)
    }

    
    func testCommandTypeForCode() {
        XCTAssert(APDUCommand.commandTypeForCode(.Register)          == RegisterRequest.self)
        XCTAssert(APDUCommand.commandTypeForCode(.Authenticate)      == AuthenticationRequest.self)
        XCTAssert(APDUCommand.commandTypeForCode(.Version)           == VersionRequest.self)
        XCTAssert(APDUCommand.commandTypeForCode(.CheckRegister)     == nil)
        XCTAssert(APDUCommand.commandTypeForCode(.AuthenticateBatch) == nil)
    }
}
