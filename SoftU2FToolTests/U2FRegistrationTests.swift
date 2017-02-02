//
//  U2FRegistrationTests.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/31/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest
@testable import SoftU2FTool

class U2FRegistrationTests: SoftU2FTestCase {
    var makeKey:U2FRegistration? { return U2FRegistration() }

    override func tearDown() {
        let _ = U2FRegistration.deleteAll()
    }

    func testNamespace() {
        XCTAssertEqual(U2FRegistration.namespace, "SoftU2F Tests")
        XCTAssertEqual(U2FRegistration.applicationLabel as String, "SoftU2F Tests")
    }

    func testCount() {
        XCTAssertEqual(U2FRegistration.count(), 0)

        XCTAssertNotNil(makeKey)
        XCTAssertEqual(U2FRegistration.count(), 2)

        XCTAssertNotNil(makeKey)
        XCTAssertEqual(U2FRegistration.count(), 4)

        let key = makeKey
        XCTAssertNotNil(key)
        XCTAssertEqual(U2FRegistration.count(), 6)

        XCTAssertTrue(key?.delete() ?? false)
        XCTAssertEqual(U2FRegistration.count(), 4)
    }

    func testGenerateKey() {
        XCTAssertNotNil(makeKey)
        XCTAssertEqual(U2FRegistration.count(), 2)
    }

    func testFindKeyByKeyHandle() {
        guard let keyOne = makeKey else {
            XCTFail("Couldn't make key")
            return
        }

        guard let kh = keyOne.handle else {
            XCTFail("Couldn't get key handle")
            return
        }

        guard let keyTwo = U2FRegistration(keyHandle: kh) else {
            XCTFail("Couldn't lookup key")
            return
        }

        XCTAssertEqual(keyOne.handle, keyTwo.handle)
        XCTAssertEqual(keyOne.publicKeyData, keyTwo.publicKeyData)
    }

    func testDelete() {
        XCTAssertTrue(makeKey?.delete() ?? false)
        XCTAssertEqual(U2FRegistration.count(), 0)
    }

    func testKeyHandle() {
        let handle = makeKey?.handle
        XCTAssertNotNil(handle)
        XCTAssertEqual(handle?.count, 20)
    }

    func testUniqueHandles() {
        XCTAssertNotEqual(makeKey?.handle, makeKey?.handle)
    }

    func testPublicKeyData() {
        let data = makeKey?.publicKeyData
        XCTAssertNotNil(data)
        XCTAssertEqual(data?.count, MemoryLayout<U2F_EC_POINT>.size)
    }

    func testUniquePublicKeys() {
        XCTAssertNotEqual(makeKey?.publicKeyData, makeKey?.publicKeyData)
    }

    func testSignVerify() {
        guard let msg = "hello, world!".data(using: .utf8) else {
            XCTFail("Couldn't encode message")
            return
        }

        guard let key = makeKey else {
            XCTFail("Couldn't make key")
            return
        }

        guard let sig = key.sign(msg) else {
            XCTFail("Couldn't sing data")
            return
        }

        XCTAssertTrue(key.verify(data: msg, signature: sig))
    }
}
