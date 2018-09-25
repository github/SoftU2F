//
//  WebSafeBase64Tests.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 9/13/16.
//

import XCTest

@testable import SoftU2F
class WebSafeBase64Tests: XCTestCase {
    func testRoundTrip() {
        for length in 0...10 {
            let orig = Data(repeating: 0x41, count: length)
            let encoded = WebSafeBase64.encode(orig)

            XCTAssertFalse(encoded.contains("+"))
            XCTAssertFalse(encoded.contains("/"))
            XCTAssertFalse(encoded.contains("="))

            let decoded = WebSafeBase64.decode(encoded)
            XCTAssertNotNil(decoded)
            XCTAssertEqual(orig, decoded)
        }
    }
}
