//
//  CounterTest.swift
//  SoftU2FTests
//
//  Created by Benjamin P Toews on 3/12/18.
//  Copyright © 2018 GitHub. All rights reserved.
//

import XCTest

@testable import SoftU2F
class CounterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Counter.current = nil
    }

    override func tearDown() {
        Counter.current = nil
        super.tearDown()
    }

    func testCounterCurrent() {
        XCTAssertEqual(nil, Counter.current)

        Counter.current = 123
        XCTAssertEqual(123, Counter.current)

        Counter.current = 234
        XCTAssertEqual(234, Counter.current)

        Counter.current = nil
        XCTAssertEqual(nil, Counter.current)
    }

    func testCounterNext() {
        XCTAssertEqual(nil, Counter.current)
        XCTAssertEqual(0, Counter.next)
        XCTAssertEqual(1, Counter.next)
        XCTAssertEqual(2, Counter.next)
        XCTAssertEqual(3, Counter.current)
    }
}
