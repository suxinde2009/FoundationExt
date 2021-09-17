//
//  SimpleMemoryCacheTests.swift
//  FoundationExtTests
//
//  Created by SuXinDe on 2021/9/17.
//

import XCTest
@testable import FoundationExt

class SimpleMemoryCacheTests: XCTestCase {

    func tests() {
        
        let cache = SimpleMemoryCache<Int, Int>()
        let secondsToTest = 10
        
        let expection1 = expectation(description: "Insert")
        let expection2 = expectation(description: "Remove")
        
        DispatchQueue.global().async {
            var seconds = secondsToTest
            while seconds > 0 {
                sleep(1)
                for i in 0..<1000 {
                    cache[i] = i
                }
                seconds -= 1
            }
            NSLog("\(cache)")
            
            DispatchQueue.main.async {
                expection1.fulfill()
            }
            
            
        }
        
        DispatchQueue.global().async {
            var seconds = secondsToTest
            while seconds > 0 {
                sleep(1)
                cache.removeAll()
                seconds -= 1
            }
            NSLog("\(cache)")
            DispatchQueue.main.async {
                expection2.fulfill()
            }
        }
       
        
        waitForExpectations(timeout: 100, handler: nil)
    }

}
