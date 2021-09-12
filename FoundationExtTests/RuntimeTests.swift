//
//  RuntimeTests.swift
//  FoundationExtTests
//
//  Created by SuXinDe on 2021/9/12.
//

import XCTest
@testable import FoundationExt

protocol MockProtocol : class {}

class NSMockClass : NSObject {
    weak var delegate : MockProtocol?
    var varStr1 : String
    var varStr2 : String!
    var varStr3 : String?
    
    override init() {
        varStr1 = "something"
        super.init()
    }
    
    func instaceMethod1() {}
    
    func instanceMethod2() -> Bool {
        return false
    }
    
    static func staticMethod() {}
    static func staticMethod2() {}
}

class RuntimeTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRetrievingRuntimeFrameworks() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let frameworks = Runtime.shared.frameworks
        for framework in frameworks {
            NSLog("-----: \(framework.name)")
        }
        XCTAssertNoThrow(frameworks)
    }
    
    func testRetrievingRuntimeClasses() {
        let classes = Runtime.shared.classes
        for clazz in classes {
            NSLog("-----: \(clazz.name)")
        }
        XCTAssertNoThrow(classes)
    }
    
    func testRetrievingRuntimeProtocols() {
        let protocols = Runtime.shared.protocols
        for aProtocol in protocols {
            NSLog("-----: \(aProtocol.name)")
        }
        XCTAssertNoThrow(protocols)
    }
    
    func testComparingProtocols() {
        XCTAssert(Runtime.shared.protocols.first != Runtime.shared.protocols.last)
    }
}

class Class_t_Tests: XCTestCase {

    var cls : Runtime.Class_t?
    
    override func setUp() {
        super.setUp()
        cls = Runtime.Class_t.from(className: "FoundationExtTests.NSMockClass")
    }
    
    override func tearDown() {
        cls = nil
        super.tearDown()
    }
    
    func testInstantiate() {
        XCTAssertNotNil(Runtime.Class_t.instantiate(from: NSMockClass.self))
    }
    
    func testCreateInstanceAtRuntimeStatic() {
        XCTAssertNotNil(cls?.createInstance())
    }
    
    func testInvalidClassName() {
        XCTAssertNil(Runtime.Class_t.from(className: "InValidClassName"))
    }
    
    func testCommons() {
        XCTAssertNotNil(cls?.runtimeClass)
        XCTAssertNotNil(cls?.baseClass)
        XCTAssertNotNil(cls?.protocols)
        XCTAssertNotNil(cls?.props)
    }
    
    func testClassProperties(){
        XCTAssert(cls?.name.isEmpty == false)
        XCTAssert(cls?.framework?.name.isEmpty == false)
        XCTAssert((cls?.ivars.count ?? 0) > 0)
        XCTAssert((cls?.methods.count ?? 0) > 0)
    }
    
    func testMethod() {
        guard let aMethod = cls?.methods.first else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(aMethod.isValid)
        XCTAssertNotNil(aMethod.method)
        XCTAssertNotNil(aMethod.selector)
        XCTAssertNotNil(aMethod.name)
        XCTAssertNotNil(aMethod.implementation)
        XCTAssertNotNil(aMethod.arguments)
        XCTAssertNotNil(aMethod.returnType)
        XCTAssertNotNil(aMethod.typeEncoding)
    }
    
    func testMethodImplementation() {
        guard let aIMP = cls?.methods.last?.implementation else {
            XCTFail()
            return
        }
        XCTAssertNotNil(aIMP.imp)
        XCTAssertNoThrow(aIMP.block)
    }
    
    func testSelector() {
        guard let aSelector = cls?.methods.first?.selector else {
            XCTFail()
            return
        }
        
        guard let aSelector2 = cls?.methods.last?.selector else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(aSelector.isValid)
        XCTAssertNotNil(aSelector.name)
        XCTAssertNotNil(aSelector.sel)
        XCTAssertTrue(aSelector != aSelector2)
    }
    
}

class FrameworkTests: XCTestCase {
    
    var framework : Runtime.Framework_t!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        framework = Runtime.shared.frameworks.first
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFramework() {
        XCTAssertNotNil(framework.image)
        XCTAssertFalse(framework.path.isEmpty)
        XCTAssertFalse(framework.name.isEmpty)
        XCTAssertNotNil(framework.url)
        XCTAssert(framework.classes.count > 0)
    }
    
    func testDyLoad() {
        XCTAssert(self.framework.dyload() == true)
    }
    
}
