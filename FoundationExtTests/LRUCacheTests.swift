//
//  LRUCacheTests.swift
//  FoundationExtTests
//
//  Created by SuXinDe on 2021/9/27.
//

import Foundation
import XCTest
@testable import FoundationExt

class LRUCacheTests: XCTestCase {
 
    func tests() {
        let cache = LRUCache<String, Int>(2)
        cache.set("a", val: 1)
        cache.set("b", val: 2)
        assert(cache.get("a") == 1)
        cache.set("c", val: 3)
        assert(cache.get("b") == nil)
        cache.set("d", val: 4)
        assert(cache.get("a") == nil)
        assert(cache.get("c") == 3)
        assert(cache.get("d") == 4)
        cache.set("a", val: 1)
        assert(cache.get("c") == nil)
        assert(cache.get("a") == 1)
    }
    
}
