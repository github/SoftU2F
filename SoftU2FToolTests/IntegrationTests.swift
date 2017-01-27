//
//  IntegrationTests.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/27/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest

class U2FAuthenticatorTests: XCTestCase {
    func testRegister() throws {
        var rc = u2fh_global_init(u2fh_initflags(rawValue: 0))
        XCTAssertEqual(rc, U2FH_OK)
        defer { u2fh_global_done() }


        var devs:OpaquePointer? = nil
        rc = u2fh_devs_init(&devs)
        XCTAssertEqual(rc, U2FH_OK)
        XCTAssertNotNil(devs)
        defer { u2fh_devs_done(devs) }

        var maxIdx = UInt32(0xFFFFFFFF)
        while u2fh_devs_discover(devs, &maxIdx) == U2FH_NO_U2F_DEVICE {
            u2fh_devs_done(devs)
            sleep(1)

            rc = u2fh_devs_init(&devs)
            XCTAssertEqual(rc, U2FH_OK)
            XCTAssertNotNil(devs)
        }

        XCTAssertEqual(rc, U2FH_OK)
        XCTAssertEqual(maxIdx, 0)

        let appId = "https://github.com/u2f/trusted_facets"
        let challenge = "VA-qf-tVVQVuPmNI4U2_ShZNYgvaaHnMPp_EnL2dNWY"
        let challengeParamBytes = try JSONSerialization.data(withJSONObject: ["challenge": challenge, "version": "U2F_V2", "appId": appId])
        let challengeParam = String(bytes: challengeParamBytes, encoding: .utf8)!
        var response:UnsafeMutablePointer<Int8>? = nil

        rc = u2fh_register(devs, challengeParam, appId, &response, U2FH_REQUEST_USER_PRESENCE)
        XCTAssertEqual(rc, U2FH_OK)
        XCTAssertNotNil(response)

        let keyHandle = try SHA256.digest(appId.data(using: .utf8)!)
        let reg = U2FRegistration.find(keyHandle: keyHandle)
        XCTAssertNotNil(reg)
        XCTAssertTrue(reg?.deleteKeyPair() ?? true) //cleanup
    }
}
