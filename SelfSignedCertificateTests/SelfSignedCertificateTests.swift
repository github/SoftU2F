//
//  SelfSignedCertificateTests.swift
//  SelfSignedCertificateTests
//
//  Created by Benjamin P Toews on 2/7/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest
import SelfSignedCertificate

class SelfSignedCertificateTests: XCTestCase {
    func testParseX509() {
        guard let crt = SelfSignedCertificate() else { XCTFail("Error generating cert"); return }
        guard var der = crt.toDer() else { XCTFail("Error DER formatting cert"); return }
        
        let crtLen = der.count
        var parsedLen = 0
        
        der.append(Data(bytes: [0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF]))
        
        XCTAssert(SelfSignedCertificate.parseX509(der, consumed: &parsedLen), "Error parsing cert")
        XCTAssertEqual(crtLen, parsedLen)
    }
}
