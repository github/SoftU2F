//
//  SoftU2FTestCase.swift
//  SoftU2FTool
//
//  Created by Benjamin P Toews on 1/30/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

import XCTest
@testable import SoftU2FTool

class SoftU2FTestCase:XCTestCase {
    override static func setUp() {
        UserPresence.shared.skip = true
        super.setUp()
    }
}
