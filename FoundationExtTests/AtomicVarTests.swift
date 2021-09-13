//
//  AtomicVarTests.swift
//  FoundationExtTests
//
//  Created by SuXinDe on 2021/9/10.
//

import XCTest
@testable import FoundationExt

class AtomicVarTests: XCTestCase {

    
    fileprivate class TestObject: NSObject {
        var v: String? = nil
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
            
            
            
            
            
        }
    }
    
    
    func testMainThreadReadWriteIntValue() {
        let expectation1 = expectation(description: "TestMainThreadReadWriteIntValue")
        var intValue: Int = 0
        
        DispatchQueue.main.async {
            for i in 0...100000 {
                _ = intValue
                intValue = i
            }
            XCTAssert(intValue == 100000, "TestMainThreadReadWriteIntValue failed")
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1000, handler: nil)
    }
    
    func testMainThreadReadWriteIntAtomicvar() {
        let expectation1 = expectation(description: "testMainThreadReadWriteIntAtomicvar")
        let intAtomicVar = AtomicVar<Int>(0)
        
        DispatchQueue.main.async {
            for i in 0...100000 {
                let x = intAtomicVar.get()
                XCTAssert(x != nil, "AtomicVar access failed")
                XCTAssert(intAtomicVar.set(i) == true, "AtomicVar set failed")
            }
            
            XCTAssert(intAtomicVar.get()! == 100000, "testMainThreadReadWriteIntAtomicvar failed")
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 1000, handler: nil)
    }
    
    
    func testMultiThreadOperateOnIntAtomicVar() {
        let expectation1 = expectation(description: "testMultiThreadOperateOnIntAtomicVar1")
        let expectation2 = expectation(description: "testMultiThreadOperateOnIntAtomicVar2")
        
        let intAtomicVar = AtomicVar<Int>(0)
        
        DispatchQueue.global().async {
            NSLog("====Begin Asnyc: testMultiThreadOperateOnIntAtomicVar\n")
            for i in 0...50000 {
                let x = intAtomicVar.get()
                if x == nil {
                    NSLog("====Async AtomicVar 获取失败")
                }
                if !intAtomicVar.set(i) {
                    NSLog("====Async AtomicVar 设置失败")
                }
            }
            NSLog("====End Asnyc: testMultiThreadOperateOnIntAtomicVar\n")
            
            expectation1.fulfill()
        }
        
        NSLog("====Begin: testMultiThreadOperateOnIntAtomicVar\n")
        for i in 0...50000 {
            let x = intAtomicVar.get()
            if x == nil {
                NSLog("====AtomicVar 获取失败")
            }
            if !intAtomicVar.set(i) {
                NSLog("====AtomicVar 设置失败")
            }
        }
        NSLog("====End: testMultiThreadOperateOnIntAtomicVar\n")
        expectation2.fulfill()
        waitForExpectations(timeout: 1000, handler: nil)
    }
    
    
    
    
    func excute(block: (_ intValue: Int) -> Void) {
        
    }
    
    func testAtomicInteger() {
        
        let expectation1 = expectation(description: #function)
        let atomicInteger = AtomicInteger(integer: 0)
        var normalInteger = 0
        
        
        let group = DispatchGroup()
        
        group.enter()
        DispatchQueue(label: "queue1").async {
            for _ in 0..<10000 {
                atomicInteger.increment()
                normalInteger += 1
            }
            group.leave()
        }
        
        group.enter()
        DispatchQueue(label: "queue2").async {
            for _ in 0..<10000 {
                atomicInteger.increment()
                normalInteger += 1
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            DispatchQueue.main.async {
                let expectedValue = 20000
               
                XCTAssert(atomicInteger.get() == expectedValue, "failed")
                expectation1.fulfill()
                
            }
        }
        
        waitForExpectations(timeout: 1000, handler: nil)
    }
    
    func testCases() {
        
       
        
        
        var stringValue: String? = ""
        var stringAtomicVar = AtomicVar<String>("")
        
        var objectValue: TestObject? = TestObject.init()
        var objectAtomicVar = AtomicVar<TestObject>(TestObject())
        
        
       
        
      
    }

}





    
    
    
   
    
//    override func debugAction() {
//        var actions: [UIAlertAction] = []
//
//

//        actions.append(UIAlertAction.init(title: "主线程读写stringValue",
//                                          style: .default,
//                                          handler:
//                                            { (sender) in
//                                                NSLog("====Begin: \(sender.title ?? "")\n")
//                                                for i in 0...100000 {
//                                                    _ = self.stringValue
//                                                    self.stringValue = "\(i)"
//                                                }
//                                                NSLog("====End: \(sender.title ?? "")\n")
//                                            }))
//
//        actions.append(UIAlertAction.init(title: "主线程读写stringAtomicVar",
//                                          style: .default,
//                                          handler:
//                                            { (sender) in
//                                                NSLog("====Begin: \(sender.title ?? "")\n")
//                                                for i in 0...100000 {
//                                                    let x = self.stringAtomicVar.get()
//                                                    if x == nil {
//                                                        NSLog("====AtomicVar 获取失败")
//                                                    }
//                                                    if !self.stringAtomicVar.set("\(i)") {
//                                                        NSLog("====AtomicVar 设置失败")
//                                                    }
//                                                }
//                                                NSLog("====End: \(sender.title ?? "")\n")
//                                            }))
//
//        actions.append(UIAlertAction.init(title: "多线程读写stringAtomicVar",
//                                          style: .default,
//                                          handler:
//                                            { (sender) in
//                                                DispatchQueue.global().async {
//                                                    NSLog("====Begin Asnyc: \(sender.title ?? "")\n")
//                                                    for i in 0...50000 {
//                                                        let x = self.stringAtomicVar.get()
//                                                        if x == nil {
//                                                            NSLog("====Async AtomicVar 获取失败")
//                                                        }
//                                                        if !self.stringAtomicVar.set("\(i)") {
//                                                            NSLog("====Async AtomicVar 设置失败")
//                                                        }
//                                                    }
//                                                    NSLog("====End Asnyc: \(sender.title ?? "")\n")
//                                                }
//
//                                                NSLog("====Begin: \(sender.title ?? "")\n")
//                                                for i in 0...50000 {
//                                                    let x = self.stringAtomicVar.get()
//                                                    if x == nil {
//                                                        NSLog("====AtomicVar 获取失败")
//                                                    }
//                                                    if !self.stringAtomicVar.set("\(i)") {
//                                                        NSLog("====AtomicVar 设置失败")
//                                                    }
//                                                }
//                                                NSLog("====End: \(sender.title ?? "")\n")
//                                            }))
//
//        actions.append(UIAlertAction.init(title: "主线程读写objectValue",
//                                          style: .default,
//                                          handler:
//                                            { (sender) in
//                                                NSLog("====Begin: \(sender.title ?? "")\n")
//                                                for _ in 0...100000 {
//                                                    _ = self.objectValue
//                                                    self.objectValue = TestObject.init()
//                                                }
//                                                NSLog("====End: \(sender.title ?? "")\n")
//                                            }))
//
//        actions.append(UIAlertAction.init(title: "主线程读写objectAtomicVar",
//                                          style: .default,
//                                          handler:
//                                            { (sender) in
//                                                NSLog("====Begin: \(sender.title ?? "")\n")
//                                                for _ in 0...100000 {
//                                                    let x = self.objectAtomicVar.get()
//                                                    if x == nil {
//                                                        NSLog("====AtomicVar 获取失败")
//                                                    }
//                                                    if !self.objectAtomicVar.set(TestObject.init()) {
//                                                        NSLog("====AtomicVar 设置失败")
//                                                    }
//                                                }
//                                                NSLog("====End: \(sender.title ?? "")\n")
//                                            }))
//
//        actions.append(UIAlertAction.init(title: "多线程读写objectAtomicVar",
//                                          style: .default,
//                                          handler:
//                                            { (sender) in
//                                                DispatchQueue.global().async {
//                                                    NSLog("====Begin Asnyc: \(sender.title ?? "")\n")
//                                                    for _ in 0...50000 {
//                                                        let x = self.objectAtomicVar.get()
//                                                        if x == nil {
//                                                            NSLog("====Async AtomicVar 获取失败")
//                                                        }
//                                                        if !self.objectAtomicVar.set(TestObject.init()) {
//                                                            NSLog("====Async AtomicVar 设置失败")
//                                                        }
//                                                    }
//                                                    NSLog("====End Asnyc: \(sender.title ?? "")\n")
//                                                }
//
//                                                NSLog("====Begin: \(sender.title ?? "")\n")
//                                                for _ in 0...50000 {
//                                                    let x = self.objectAtomicVar.get()
//                                                    if x == nil {
//                                                        NSLog("====AtomicVar 获取失败")
//                                                    }
//                                                    if !self.objectAtomicVar.set(TestObject.init()) {
//                                                        NSLog("====AtomicVar 设置失败")
//                                                    }
//                                                }
//                                                NSLog("====End: \(sender.title ?? "")\n")
//                                            }))
//
//        showSheetActions(actions)
//    }
