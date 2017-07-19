//
//  IntegrationTests.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/27/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest
import APDU

@testable import SoftU2FTool
class IntegrationTests: SoftU2FTestCase {
    override func tearDown() {
        let _ = U2FRegistration.deleteAll()
    }

    func testRegister() throws {
//        var rc = u2fh_global_init(u2fh_initflags(rawValue: 0))
        var rc = u2fh_global_init(U2FH_DEBUG)
        XCTAssertEqual(rc.name, U2FH_OK.name)
        defer { u2fh_global_done() }


        var devs: OpaquePointer? = nil
        rc = u2fh_devs_init(&devs)
        XCTAssertEqual(rc.name, U2FH_OK.name)
        XCTAssertNotNil(devs)
        defer { u2fh_devs_done(devs) }

        var maxIdx = UInt32(0xFFFFFFFF)
        while u2fh_devs_discover(devs, &maxIdx) == U2FH_NO_U2F_DEVICE {
            u2fh_devs_done(devs)
            sleep(1)

            rc = u2fh_devs_init(&devs)
            XCTAssertEqual(rc.name, U2FH_OK.name)
            XCTAssertNotNil(devs)
        }

        XCTAssertEqual(rc.name, U2FH_OK.name)
        XCTAssertEqual(maxIdx, 0)

        let appId = "https://github.com/u2f/trusted_facets"
        let challenge = "VA-qf-tVVQVuPmNI4U2_ShZNYgvaaHnMPp_EnL2dNWY"
        let challengeParamBytes = try JSONSerialization.data(withJSONObject: ["challenge": challenge, "version": "U2F_V2", "appId": appId])
        let challengeParam = String(bytes: challengeParamBytes, encoding: .utf8)!
        var respPtr: UnsafeMutablePointer<Int8>? = nil

        rc = u2fh_register(devs, challengeParam, appId, &respPtr, U2FH_REQUEST_USER_PRESENCE)
        XCTAssertEqual(rc.name, U2FH_OK.name)

        if respPtr == nil {
            XCTFail("Expected registration response")
            return
        }

        let respStr = String(cString: respPtr!)

        guard let respData = respStr.data(using: .utf8) else {
            XCTFail("Expected response to utf8 encoded")
            return
        }

        let respJSON = try JSONSerialization.jsonObject(with: respData, options: JSONSerialization.ReadingOptions.init(rawValue: 0))

        guard let respDict = respJSON as? [String: String] else {
            XCTFail("Expected response to be dictionary")
            return
        }

        guard let regDataStr = respDict["registrationData"] else {
            XCTFail("Expected response dictionary to include registrationData member")
            return
        }

        guard let regData = WebSafeBase64.decode(regDataStr) else {
            XCTFail("Expected response registrationData member to be b64 encoded")
            return
        }

        // TODO: this fails because we include the APDU trailer in the RegisterResponse....
        let regResp = try APDU.RegisterResponse(raw: regData, bodyOnly: true)

        guard let _ = U2FRegistration(keyHandle: regResp.keyHandle, applicationParameter: SHA256.digest(appId)) else {
            XCTFail("Expected key handle from response to match registration")
            return
        }
    }
}
