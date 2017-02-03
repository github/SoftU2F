//
//  U2FHIDTests.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/25/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest

@testable import SoftU2FTool
class U2FHIDTests: XCTestCase {
    func testInit() {
        XCTAssertNotNil(U2FHID.shared)
    }

    func testOnlySingleton() {
        XCTAssertNil(U2FHID())
    }

    func testHandleMsg() {
        U2FHID.shared?.handle(.Msg) { (_ msg: softu2f_hid_message) -> Bool in
            return true
        }
    }
}
