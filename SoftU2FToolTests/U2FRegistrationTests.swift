//
//  U2FRegistrationTests.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/31/17.
//

import XCTest
@testable import SoftU2F

class U2FRegistrationTests: SoftU2FTestCase {
    var makeKey: U2FRegistration? { return U2FRegistration(applicationParameter: randData(length: 32), inSEP: false) }

    override func tearDown() {
        let _ = U2FRegistration.deleteAll()
    }

    func testNamespace() {
        XCTAssertEqual(U2FRegistration.namespace, "SoftU2F Tests")
    }

    func testCount() {
        XCTAssertEqual(U2FRegistration.count, 0)

        XCTAssertNotNil(makeKey)
        XCTAssertEqual(U2FRegistration.count, 1)

        XCTAssertNotNil(makeKey)
        XCTAssertEqual(U2FRegistration.count, 2)

        let key = makeKey
        XCTAssertNotNil(key)
        XCTAssertEqual(U2FRegistration.count, 3)

        XCTAssertTrue(key?.keyPair.delete() ?? false)
        XCTAssertEqual(U2FRegistration.count, 2)
    }

    func testGenerateKey() {
        XCTAssertNotNil(makeKey)
        XCTAssertEqual(U2FRegistration.count, 1)
    }

    func testFindKeyByKeyHandleAndAppParam() {
        guard let keyOne = makeKey else {
            XCTFail("Couldn't make key")
            return
        }

        guard let keyTwo = U2FRegistration(keyHandle: keyOne.keyHandle, applicationParameter: keyOne.applicationParameter) else {
            XCTFail("Couldn't lookup key")
            return
        }

        XCTAssertEqual(keyOne.keyHandle, keyTwo.keyHandle)
        XCTAssertEqual(keyOne.keyPair.publicKeyData, keyTwo.keyPair.publicKeyData)
    }

    func testFindKeyWithWrongAppParam() {
        guard let keyOne = makeKey else {
            XCTFail("Couldn't make key")
            return
        }

        guard let keyTwo = makeKey else {
            XCTFail("Couldn't make key")
            return
        }

        let found = U2FRegistration(keyHandle: keyOne.keyHandle, applicationParameter: keyTwo.applicationParameter)
        XCTAssertNil(found)
    }

    func testDelete() {
        XCTAssertTrue(makeKey?.keyPair.delete() ?? false)
        XCTAssertEqual(U2FRegistration.count, 0)
    }

    func testKeyHandle() {
        let handle = makeKey?.keyHandle
        XCTAssertNotNil(handle)
        XCTAssertEqual(handle?.count, 70)
    }

    func testUniqueHandles() {
        XCTAssertNotEqual(makeKey?.keyHandle, makeKey?.keyHandle)
    }

    func testPublicKeyData() {
        let data = makeKey?.keyPair.publicKeyData
        XCTAssertNotNil(data)
        XCTAssertEqual(data?.count, MemoryLayout<U2F_EC_POINT>.size)
    }

    func testUniquePublicKeys() {
        XCTAssertNotEqual(makeKey?.keyPair.publicKeyData, makeKey?.keyPair.publicKeyData)
    }

    func testSignVerify() {
        let msg = "hello, world!".data(using: .utf8)!

        guard let key = makeKey else {
            XCTFail("Couldn't make key")
            return
        }

        guard let sig = key.sign(msg) else {
            XCTFail("Couldn't sing data")
            return
        }

        XCTAssertTrue(key.keyPair.verify(data: msg, signature: sig))
    }
}
