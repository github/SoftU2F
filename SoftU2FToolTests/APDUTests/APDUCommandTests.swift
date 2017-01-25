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
        let c = try SHA256.digest("world".data(using: String.Encoding.utf8)!)
        let a = try SHA256.digest("hello".data(using: String.Encoding.utf8)!)
        let r = RegisterRequest(challengeParameter: c, applicationParameter: a)

        do {
            let cmd1 = try APDUCommand(data: r)

            do {
                let cmd2 = try APDUCommand(raw: cmd1.raw)

                XCTAssertEqual(cmd1.header.raw, cmd2.header.raw)
                XCTAssertEqual(cmd1.data.raw, cmd2.data.raw)
            } catch let err {
                XCTFail("Error making APDUCommand from raw: " + err.localizedDescription)
            }
        } catch let err {
            XCTFail("Error making APDUCommand from data: " + err.localizedDescription)
        }
    }
    
    func testCommandTypeForCode() {
        XCTAssert(APDUCommand.commandTypeForCode(.Register)          == RegisterRequest.self)
        XCTAssert(APDUCommand.commandTypeForCode(.Authenticate)      == AuthenticationRequest.self)
        XCTAssert(APDUCommand.commandTypeForCode(.Version)           == nil)
        XCTAssert(APDUCommand.commandTypeForCode(.CheckRegister)     == nil)
        XCTAssert(APDUCommand.commandTypeForCode(.AuthenticateBatch) == nil)
    }
}
