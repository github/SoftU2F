//
//  APDUResponseTests.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/12/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import XCTest

class APDUResponseTests: XCTestCase {
    func testRoundTrip() throws {
        let pk = randData(length: MemoryLayout<U2F_EC_POINT>.size)
        let kh = randData(length: 50)
        let crt:Data = SelfSignedCertificate().toDer()
        let sig = randData(length: 20)
        
        let d = RegisterResponse(publicKey: pk, keyHandle: kh, certificate: crt, signature: sig)
        let r1 = APDUResponse(data: d)
        let r2 = try APDUResponse<RegisterResponse>(raw: r1.raw)
        
        XCTAssertEqual(r1.raw, r2.raw)
        XCTAssertEqual(d.raw, r2.data.raw)
    }
}
