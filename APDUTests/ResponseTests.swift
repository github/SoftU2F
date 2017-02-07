//
//  ResponseTests.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 9/12/16.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest
import SelfSignedCertificate

class ResponseTests: XCTestCase {
    func testRegisterResponse() throws {
        let pk = randData(length: U2F_EC_POINT_SIZE)
        let kh = randData(length: 50)
        let crt: Data = SelfSignedCertificate().toDer()
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

    func testParseRegisterResponse() throws {
        let raw = Data(base64Encoded: "BQR2utsw0prAOLWD8fr5EaKZg3/rqA/jbqaRFVAzMapgG9vGUAwipMHi5uB8UtFuGDTFYuvorNjrd1JScUAOufUUIFVnO1E4zJDTt/Mr/a1qOKjt17NVt3q5eSGW8QbRbKMSMIICCjCCAbGgAwIBAgIBATAKBggqhkjOPQQDAjAVMRMwEQYDVQQDDAptYXN0YWh5ZXRpMB4XDTE3MDEyNzAwNTkzN1oXDTE3MDEyODAwNTkzN1owFTETMBEGA1UEAwwKbWFzdGFoeWV0aTCCAUswggEDBgcqhkjOPQIBMIH3AgEBMCwGByqGSM49AQECIQD/////AAAAAQAAAAAAAAAAAAAAAP///////////////zBbBCD/////AAAAAQAAAAAAAAAAAAAAAP///////////////AQgWsY12Ko6k+ez671VdpiGvGUdBrDMU7D2O848PifSYEsDFQDEnTYIhucEk2pmeOETnSa3gZ9+kARBBGsX0fLhLEJH+Lzm5WOkQPJ3A32BLeszoPShOUXYmMKWT+NC4v4af5uO5+tKfA+eFivOM1drMV7Oy7ZAaDe/UfUCIQD/////AAAAAP//////////vOb6racXnoTzucrC/GMlUQIBAQNCAATeJgyp/T90ALpOLTElPbKD4Z9odWgXspLyYj2rOz5lewET+7t4LZox2J9KhyEH1wCWRfjj0eZ8xcwpeVr4EK6uMAoGCCqGSM49BAMCA0cAMEQCIBM9VTWezfE6DvBV/CwiH++kAIK4H5TdHpgQF6g4WP/nAiBMOmzCpp6MKJy9xTLOZJeLHwzV1QR6stT/McDiWPwDWDBFAiAI4CeUk2Xdt/lv1KV4gUUujqJI/TiVpLCTJmyRe/AuIAIhAJo2jVdEV5YkOySVvO7q5MD55UYyeduNoDIqzR0kt318kAA=")!
        let res = try RegisterResponse(raw: raw)

        XCTAssertEqual(res.raw, raw)
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
