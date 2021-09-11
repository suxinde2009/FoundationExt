//
//  StorageExpirationTests.swift
//  FoundationExtTests
//
//  Created by SuXinDe on 2021/9/11.
//

import XCTest
@testable import FoundationExt

class StorageExpirationTests: XCTestCase {

    func testExpirationNever() {
        let e = StorageExpiration.never
        XCTAssertEqual(e.estimatedExpirationSinceNow, .distantFuture)
        XCTAssertEqual(e.timeInterval, .infinity)
        XCTAssertFalse(e.isExpired)
    }
    
    func testExpirationSeconds() {
        let e = StorageExpiration.seconds(100)
        XCTAssertEqual(
            e.estimatedExpirationSinceNow.timeIntervalSince1970,
            Date().timeIntervalSince1970 + 100,
            accuracy: 0.1)
        XCTAssertEqual(e.timeInterval, 100)
        XCTAssertFalse(e.isExpired)
    }
    
    func testExpirationDays() {
        let e = StorageExpiration.days(1)
        let oneDayInSecond = TimeInterval(TimeConstants.secondsInOneDay)
        XCTAssertEqual(
            e.estimatedExpirationSinceNow.timeIntervalSince1970,
            Date().timeIntervalSince1970 + oneDayInSecond,
            accuracy: 0.1)
        XCTAssertEqual(e.timeInterval, oneDayInSecond, accuracy: 0.1)
        XCTAssertFalse(e.isExpired)
    }
    
    func testExpirationDate() {
        let oneDayInSecond = TimeInterval(TimeConstants.secondsInOneDay)
        let targetDate = Date().addingTimeInterval(oneDayInSecond)
        let e = StorageExpiration.date(targetDate)
        XCTAssertEqual(
            e.estimatedExpirationSinceNow.timeIntervalSince1970,
            Date().timeIntervalSince1970 + oneDayInSecond,
            accuracy: 0.1)
        XCTAssertEqual(e.timeInterval, oneDayInSecond, accuracy: 0.1)
        XCTAssertFalse(e.isExpired)
    }
    
    func testAlreadyExpired() {
        let e = StorageExpiration.expired
        XCTAssertTrue(e.isExpired)
        XCTAssertEqual(e.estimatedExpirationSinceNow, .distantPast)
    }

}
