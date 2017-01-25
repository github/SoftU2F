//
//  SelfSignedCertificateTests.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/25/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest

class SelfSignedCertificateTests: XCTestCase {
    func testParseX509() {
        guard let crt = SelfSignedCertificate() else { XCTFail("Error generating cert");     return }
        guard var der = crt.toDer()             else { XCTFail("Error DER formatting cert"); return }

        let crtLen = der.count
        var parsedLen = 0

        der.append(randData())

        XCTAssert(SelfSignedCertificate.parseX509(der, consumed: &parsedLen), "Error parsing cert")
        XCTAssertEqual(crtLen, parsedLen)
    }
}
