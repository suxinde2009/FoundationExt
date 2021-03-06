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
        cache.set("a", 1)
        cache.set("b", 2)
        assert(cache.get("a") == 1)
        cache.set("c", 3)
        assert(cache.get("b") == nil)
        cache.set("d", 4)
        assert(cache.get("a") == nil)
        assert(cache.get("c") == 3)
        assert(cache.get("d") == 4)
        cache.set("a", 1)
        assert(cache.get("c") == nil)
        assert(cache.get("a") == 1)
        
        cache["e"] = 3
        assert(cache["e"] == 3)
        
        cache["a"] = nil
        assert(cache["a"] == nil)
        
        NSLog("\(cache)")
        
    }
    
}
