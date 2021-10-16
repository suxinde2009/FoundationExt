//
//  CountableTests.swift
//  FoundationExtTests
//
//  Created by SuXinDe on 2021/10/16.
//

import XCTest
@testable import FoundationExt


class CountableTests: XCTestCase {

    let array = [0,1,2,3,4,5,6,7,8,9]
    
    func testRepeat() {
        XCTAssertEqual(array.repeat(5), 5)
        XCTAssertEqual(array.repeat(13), 3)
        XCTAssertEqual(array.repeat(20), 0)
        XCTAssertEqual(array.repeat(35), 5)
        XCTAssertEqual(array.repeat(-3), 7)
        XCTAssertEqual(array.repeat(-5), 5)
        XCTAssertEqual(array.repeat(-13), 7)
        XCTAssertEqual(array.repeat(-20), 0)
        XCTAssertEqual(array.repeat(-35), 5)
    }
    
    func testThreshold() {
        XCTAssertEqual(array.threshold(with: 5), .in)
        XCTAssertEqual(array.threshold(with: 13), .above)
        XCTAssertEqual(array.threshold(with: 20), .above)
        XCTAssertEqual(array.threshold(with: 35), .above)
        XCTAssertEqual(array.threshold(with: -5), .below)
        XCTAssertEqual(array.threshold(with: -13), .below)
        XCTAssertEqual(array.threshold(with: -20), .below)
        XCTAssertEqual(array.threshold(with: -35), .below)
    }

}
