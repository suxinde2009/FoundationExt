//
//  GCDTimerTests.swift
//  FoundationExtTests
//
//  Created by SuXinDe on 2021/11/23.
//

import XCTest
@testable import FoundationExt

class GCDTimerTests: XCTestCase {

    func testSingleTimer() {
        
        let expectation = self.expectation(description: "timer fire")
        
        let timer = GCDTimer(interval: .seconds(2)) { _ in
            print("timer fire")
            expectation.fulfill()
        }
        timer.start()
        self.waitForExpectations(timeout: 2.01, handler: nil)
    }
    
    func testRepeaticTimer() {
        
        let expectation = self.expectation(description: "timer fire")
        
        var count = 0
        let timer = GCDTimer.repeaticTimer(interval: .seconds(1)) { _ in
            count = count + 1
            if count == 2 {
                expectation.fulfill()
            }
        }
        timer.start()
        self.waitForExpectations(timeout: 2.01, handler: nil)
    }
    
    func testTimerAndInternalTimerRetainCycle() {
        
        //let expectation = self.expectation(description: "test deinit")
        var count = 0
        weak var weakReference: GCDTimer?
        do {
            let timer = GCDTimer.repeaticTimer(interval: .seconds(1)) { _ in
                count += 1
                print(count)
            }
            weakReference = timer
            timer.start()
        }
        XCTAssertNil(weakReference)
    }
    
    func testDebounce() {
        
        let expectation = self.expectation(description: "test debounce")
        
        var count = 0
        let timer = GCDTimer.repeaticTimer(interval: .seconds(1)) { _ in
            
            GCDTimer.debounce(interval: .fromSeconds(1.5), identifier: "not pass") { [weak expectation] in
                //even testDebounce success. the internal timer won't stop.
                //it will cause another test method fail
                //I think XCTest framework should not call fail if XCFail is not in other test method
                if (expectation != nil) {
                    XCTFail("should not pass")
                }
            }
            
            GCDTimer.debounce(interval: .fromSeconds(0.5), identifier:  "pass") {
                count = count + 1
                if count == 4 {
                    expectation.fulfill()
                }
            }
        }
        timer.start()
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testThrottle() {
        
        let expectation = self.expectation(description: "test throttle")
        
        var count = 0
        var temp = 0
        let timer = GCDTimer.repeaticTimer(interval: .fromSeconds(0.1)) { _ in
            GCDTimer.throttle(interval: .fromSeconds(1), identifier: "throttle", handler: {
                count = count + 1
                if count > 3 {
                    XCTFail("should not pass")
                }
                print(count)
            })
            temp = temp + 1
            print("temp: \(temp)")
            if temp == 30 {
                expectation.fulfill()
            }
        }
        timer.start()
        self.waitForExpectations(timeout: 3.2, handler: nil)
    }
    
    func testRescheduleRepeating() {
        
        let expectation = self.expectation(description: "rescheduleRepeating")
        
        var count = 0
        let timer = GCDTimer.repeaticTimer(interval: .seconds(1)) { timer in
            count = count + 1
            print(Date())
            if count == 3 {
                timer.rescheduleRepeating(interval: .seconds(3))
            }
            if count == 4 {
                expectation.fulfill()
            }
        }
        timer.start()
        self.waitForExpectations(timeout: 6.1, handler: nil)
    }
    
    func testRescheduleHandler() {
        
        let expectation = self.expectation(description: "RescheduleHandler")
        
        let timer = GCDTimer(interval: .seconds(2)) { _ in
            print("should not pass")
        }
        timer.rescheduleHandler { _ in
            expectation.fulfill()
        }
        timer.start()
        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testCountDownTimer() {
        
        let expectation = self.expectation(description: "test count down timer")
        
        let label = UILabel()
        
        let timer = GCDCountDownTimer(interval: .fromSeconds(0.1), times: 10) { _, leftTimes in
            label.text = "\(leftTimes)"
            print(label.text!)
            if label.text == "0" {
                expectation.fulfill()
            }
        }
        timer.start()
        
        self.waitForExpectations(timeout: 1.01, handler: nil)
        
    }

}
