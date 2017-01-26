//
//  APDUResponseTests.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/12/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest

class APDUResponseTests: XCTestCase {
    func testRegisterResponse() throws {
        let pk = randData(length: MemoryLayout<U2F_EC_POINT>.size)
        let kh = randData(length: 50)
        let crt:Data = SelfSignedCertificate().toDer()
        let sig = randData(length: 20)
        
        let r = RegisterResponse(publicKey: pk, keyHandle: kh, certificate: crt, signature: sig)
        let r2 = try RegisterResponse(raw: r.raw)

        XCTAssertEqual(r2.publicKey, r.publicKey)
        XCTAssertEqual(r2.keyHandle, r.keyHandle)
        XCTAssertEqual(r2.certificate, r.certificate)
        XCTAssertEqual(r2.signature, r.signature)
        XCTAssertEqual(r2.status, r.status)
        XCTAssertEqual(r.raw, r2.raw)
    }

    func testVersionResponse() throws {
        let r = VersionResponse(version: "FOOBAR")
        let r2 = try VersionResponse(raw: r.raw)

        XCTAssertEqual(r.version, r2.version)
        XCTAssertEqual(r.status, r2.status)
        XCTAssertEqual(r.raw, r2.raw)
    }

    func testErrorResponse() throws {
        let r = ErrorResponse(status: .ConditionsNotSatisfied)
        let r2 = try ErrorResponse(raw: r.raw)

        XCTAssertEqual(r.status, r2.status)
        XCTAssertEqual(r.raw, r2.raw)
    }
}
