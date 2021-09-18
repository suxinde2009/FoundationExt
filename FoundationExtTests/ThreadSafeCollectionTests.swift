//
//  ThreadSafeCollectionTests.swift
//  FoundationExtTests
//
//  Created by SuXinDe on 2021/9/18.
//

import XCTest
@testable import FoundationExt

class ThreadSafeCollectionTests: XCTestCase {

    func testArrays() {
        
        let exp1 = expectation(description: "Array")
        let exp2 = expectation(description: "ThreadSafeArray")
        
        let thread = FIFOThread()
    
        var array = [Int]()
        let threadSafeArray = ThreadSafeArray<Int>()
        let iterations = 10000
        
        
        thread.enqueue {
            let start = Date().timeIntervalSince1970
            for index in 0..<iterations {
                
                let last = array.last ?? 0
                array.append(last + 1)
                
                // Final loop
                guard index == ( iterations - 1) else { continue }
                let message = String(format: "Unsafe loop took %.3f seconds, count: %d.",
                                     Date().timeIntervalSince1970 - start,
                                     array.count)
                NSLog(message)
                
                DispatchQueue.main.async {
                    array.removeAll()
                    exp1.fulfill()
                }
                
            }
        }
            
        
        // Thread-safe array
        thread.enqueue {
            let start = Date().timeIntervalSince1970
            for index in 0..<iterations {
                let last = threadSafeArray.last ?? 0
                threadSafeArray.append(last + 1)
                
                // Final loop
                guard index == (iterations - 1) else { continue }
                let message = String(format: "Safe loop took %.3f seconds, count: %d.",
                                     Date().timeIntervalSince1970 - start,
                                     threadSafeArray.count)
                NSLog(message)
                
                DispatchQueue.main.async {
                    threadSafeArray.removeAll()
                    exp2.fulfill()
                }
                
            }
        }
            
        waitForExpectations(timeout: 1000, handler: nil)
    }
    
    func testDictionarys() {
        
        let exp1 = expectation(description: "Dictionary")
        let exp2 = expectation(description: "ThreadSafeDictionary")
        
        let thread = FIFOThread()
        
        var dict = [Int:Int]()
        let threadSafeDict = ThreadSafeDictionary<Int, Int>()
        let iterations = 10000
        
        
        thread.enqueue {
            let start = Date().timeIntervalSince1970
            for index in 0..<iterations {
                
                dict[index] = index
                
                // Final loop
                guard index == ( iterations - 1) else { continue }
                let message = String(format: "Unsafe loop took %.3f seconds, count: %d.",
                                     Date().timeIntervalSince1970 - start,
                                     dict.count)
                NSLog(message)
                
                DispatchQueue.main.async {
                    dict.removeAll()
                    exp1.fulfill()
                } 
            }
        }
        
        
        // Thread-safe array
        thread.enqueue {
            let start = Date().timeIntervalSince1970
            for index in 0..<iterations {
                
                threadSafeDict[index] = index
                
                // Final loop
                guard index == (iterations - 1) else { continue }
                let message = String(format: "Safe loop took %.3f seconds, count: %d.",
                                     Date().timeIntervalSince1970 - start,
                                     threadSafeDict.count)
                NSLog(message)
                
                DispatchQueue.main.async {
                    threadSafeDict.removeAll()
                    exp2.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 1000, handler: nil)
        
    }
    

}
