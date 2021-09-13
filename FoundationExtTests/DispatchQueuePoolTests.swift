//
//  DispatchQueuePoolTests.swift
//  FoundationExtTests
//
//  Created by SuXinDe on 2021/9/13.
//

import XCTest
@testable import FoundationExt

class DispatchQueuePoolTests: XCTestCase {

    func tests() {
        
        let conditionNumber = 10000
        
        let exp1 = expectation(description: "utility")
        let exp2 = expectation(description: "userInteractive")
        let exp3 = expectation(description: "default")
        let exp4 = expectation(description: "userInitiated")
        let exp5 = expectation(description: "background")
        
        for i in 0..<conditionNumber {
            DispatchQueuePool.utility.async {
                NSLog("\(DispatchQueuePool.utility.name) -- [\(i)], current thread[ \(String(describing: Thread.current)) ], activeProcessorCount: \(ProcessInfo.processInfo.activeProcessorCount)")
                if i == conditionNumber-1 {
                    exp1.fulfill()
                }
            }
            
            DispatchQueuePool.userInteractive.async {
                NSLog("\(DispatchQueuePool.userInteractive.name) -- [\(i)], current thread[ \(String(describing: Thread.current)) ], activeProcessorCount: \(ProcessInfo.processInfo.activeProcessorCount)")
                if i == conditionNumber-1 {
                    exp2.fulfill()
                }
            }
            
            DispatchQueuePool.default.async {
                NSLog("\(DispatchQueuePool.default.name) -- [\(i)], current thread[ \(String(describing: Thread.current)) ], activeProcessorCount: \(ProcessInfo.processInfo.activeProcessorCount)")
                if i == conditionNumber-1 {
                    exp3.fulfill()
                }
            }
            
            DispatchQueuePool.userInitiated.async {
                NSLog("\(DispatchQueuePool.userInitiated.name) -- [\(i)], current thread[ \(String(describing: Thread.current)) ], activeProcessorCount: \(ProcessInfo.processInfo.activeProcessorCount)")
                if i == conditionNumber-1 {
                    exp4.fulfill()
                }
            }
            
            DispatchQueuePool.background.async {
                NSLog("\(DispatchQueuePool.background.name) -- [\(i)], current thread[ \(String(describing: Thread.current)) ], activeProcessorCount: \(ProcessInfo.processInfo.activeProcessorCount)")
                if i == conditionNumber-1 {
                    exp5.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 1000, handler: nil)
    }

}
