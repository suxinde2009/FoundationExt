//
//  FIFOThreadTests.swift
//  FoundationExtTests
//
//  Created by SuXinDe on 2021/9/10.
//

import Foundation
import XCTest
@testable import FoundationExt

class FIFOThreadTests: XCTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEnqueueSingle() {
        let expectation1 = expectation(description: "First")
        
        let thread = FIFOThread()
        thread.enqueue {
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEnqueueMultiple() {
        let expectation1 = expectation(description: "First")
        let expectation2 = expectation(description: "Second")
        
        let thread = FIFOThread()
        var visitedFirst = false
        thread.enqueue {
            expectation1.fulfill()
            visitedFirst = true
        }
        thread.enqueue {
            expectation2.fulfill()
            XCTAssert(visitedFirst, "Didn't run first before this secondary block")
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCancel() {
        let expectation1 = expectation(description: "First")
        let expectationWait = expectation(description: "Wait")
        
        let thread = FIFOThread()
        thread.enqueue {
            thread.cancel()
            expectation1.fulfill()
        }
        thread.enqueue {
            XCTFail("This block is enqueued after first block, so shouldn't be run")
        }
        
        asyncAfter(seconds: 0.1) {
            expectationWait.fulfill()
        }
        
        // Wait
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEmptyQueue() {
        let expectation1 = expectation(description: "First")
        let expectationWait = expectation(description: "Wait")
        
        let thread = FIFOThread()
        thread.enqueue {
            expectation1.fulfill()
            Thread.sleep(forTimeInterval: 0.1)
        }
        thread.enqueue {
            XCTFail("This block is enqueued after first block, so shouldn't be run")
        }
        
        DispatchQueue.main.async {
            XCTAssertEqual(thread.queue.count, 1)
            thread.emptyQueue()
            XCTAssertEqual(thread.queue.count, 0)
        }
        
        asyncAfter(seconds: 0.2) {
            expectationWait.fulfill()
        }
        
        // Wait
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPause() {
        let expectation1 = expectation(description: "First")
        let expectation2 = expectation(description: "Second")
        let expectationWait = expectation(description: "Wait")
        
        let thread = FIFOThread()
        var paused: Bool = false
        var resumed: Bool = false
        thread.enqueue {
            paused = true
            thread.pause()
            XCTAssert(thread.paused, "Should be in paused state")
            expectation1.fulfill()
        }
        thread.enqueue {
            XCTAssert(paused, "Should have been stopped once")
            XCTAssert(resumed, "Should have been restarted again")
            expectation2.fulfill()
        }
        
        asyncAfter(seconds: 0.1) {
            expectationWait.fulfill()
            resumed = true
            thread.resume()
            XCTAssertFalse(thread.paused, "Shouldn't be in paused state")
        }
        
        // Wait
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testInitialQueue() {
        let thread = FIFOThread(start: false, queue: [{}, {}, {}])
        XCTAssertEqual(thread.queue.count, 3, "Thread initialized with 3 blocks.")
    }
}


extension FIFOThreadTests {
    
    private func asyncAfter(seconds: Double,
                            queue: DispatchQueue = DispatchQueue.main,
                            block: @escaping () -> Void) {
        
        let time = DispatchTime.now() + seconds
        
        at(time: time,
           block: block,
           queue: queue)
    }
    
    private func at(time: DispatchTime,
                    block: @escaping () -> Void, queue: DispatchQueue) {
        // See Async.async() for comments
        queue.asyncAfter(
            deadline: time,
            execute: block
        )
    }
}
