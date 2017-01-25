//
//  WebSafeBase64Tests.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/13/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import XCTest

class WebSafeBase64Tests: XCTestCase {
    func testRoundTrip() {
        for length in 0...10 {
            let orig = Data(repeating: 0x41, count: length)
            let encoded = WebSafeBase64.encodeData(orig)

            XCTAssertNil(encoded.characters.index(of: Character("+")))
            XCTAssertNil(encoded.characters.index(of: Character("/")))
            XCTAssertNil(encoded.characters.index(of: Character("=")))
            
            let decoded = WebSafeBase64.decodeString(encoded)
            XCTAssertNotNil(decoded)
            XCTAssertEqual(orig, decoded)
        }
    }
}
