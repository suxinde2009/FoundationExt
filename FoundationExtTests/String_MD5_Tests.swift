//
//  String_MD5_Tests.swift
//  FoundationExtTests
//
//  Created by SuXinDe on 2021/9/11.
//

import XCTest
@testable import FoundationExt

class String_MD5_Tests: XCTestCase {

    func testStringMD5() {
        let s = "hello"
        XCTAssertEqual(s.md5, "5d41402abc4b2a76b9719d911017c592")
    }

}
