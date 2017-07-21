//
//  SoftU2FTestCase.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 1/30/17.
//

import XCTest
@testable import SoftU2F

class SoftU2FTestCase: XCTestCase {
    static var nameSpaceWas = U2FRegistration.namespace

    override static func setUp() {
        // Skip user notifications during TUP.
        UserPresence.skip = true

        // Use separate namespace for keychain entries.
        U2FRegistration.namespace = "SoftU2F Tests"

        // Clear any lingering keychain entries.
        let _ = U2FRegistration.deleteAll()

        super.setUp()
    }

    override static func tearDown() {
        U2FRegistration.namespace = nameSpaceWas
        UserPresence.skip = false
    }
}
