//
//  AsyncTaskQueueTests.swift
//  AsyncTaskQueueTests
//
//  Created by SuXinDe on 2021/3/13.
//  Copyright © 2021 Skyprayer Studio. All rights reserved.
//

import XCTest
@testable import FoundationExt

/// A contrived example illustrating the use of AsyncBlockOperation.
///
/// Prints the following to the console:
///
///     One.
///     Two.
///     Three.
///
func doSomethingSlow(queue: OperationQueue, completion: @escaping () -> Void) {
    
    // `AsyncBlockOperation` allows you to run arbitrary blocks of code
    // asynchronously. The only obligation is that the block must invoke the
    // `finish` block argument when finished, or else the AsyncBlockOperation
    // will remain stuck in the isExecuting state indefinitely.
    
    // For example, even though the execution blocks for the `one`, `two`, and
    // `three` operations below exit scope before each of their `.asyncAfter()`
    // calls fire, each operation will remain in its executing state until the
    // `finish` handlers are invoked. This allows you to make each operation
    // depend upon the previous via `.addDependency()`.
    
    let one = AsyncBlockOperation { (finish) in
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            print("One.")
            finish()
        }
    }
    
    let two = AsyncBlockOperation { (finish) in
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            print("Two.")
            finish()
        }
    }
    
    let three = AsyncBlockOperation { (finish) in
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            print("Three.")
            finish()
        }
    }
    
    // In contrast, (NS)BlockOperation is marked finished as soon as the outer-
    // most scope of the execution block exits.
    
    let completionOp = BlockOperation {
        completion()
    }
    
    two.addDependency(one)
    three.addDependency(two)
    completionOp.addDependency(three)
    
    let ops = [one, two, three, completionOp]
    
    queue.addOperations(ops, waitUntilFinished: false)
    
}


class AysncBlockOperationTests: XCTestCase {
    func testExecOneBlock() {
        let exp = expectation(description: #function)
        let op = AsyncBlockOperation { finish in
            exp.fulfill()
            finish()
        }
        op.start()
        waitForExpectations(timeout: 5)
    }
    
    
    func test_executesACompletionBlock() {
        let exp = expectation(description: #function)
        let op = AsyncBlockOperation { finish in
            finish()
        }
        op.addCompletionHandler {
            exp.fulfill()
        }
        op.start()
        waitForExpectations(timeout: 5)
    }
    
    func test_remainsExecutingUntilFinished() {
        let exp = expectation(description: #function)
        var results: [String] = ["idle"]
        let asyncOp = AsyncBlockOperation { finish in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                results.append("async")
                finish()
            }
        }
        let syncOp = BlockOperation {
            results.append("sync")
            XCTAssertEqual(["idle", "async", "sync"], results)
            exp.fulfill()
        }
        syncOp.addDependency(asyncOp)
        let queue = OperationQueue()
        queue.addOperations([asyncOp, syncOp], waitUntilFinished: false)
        waitForExpectations(timeout: 5)
    }
    
    func test_doSomethingSlow() {
        let queue = OperationQueue()
        doSomethingSlow(queue: queue) {
            
        }
    }
}

class AsyncTaskOperationTests: XCTestCase {
    
    private class TestAccumulator {
        var strings = [String]()
    }
    
    
    func test_executesASimpleTask() {
        
        let exp = expectation(description: #function)
        
        let task = AsyncTaskOperation<[String]>(
            task: { finish in
                let accumulator = TestAccumulator()
                accumulator.strings.append("One")
                finish(accumulator.strings)
            },
            cancellation: {
                // no op
            },
            preferredPriority: .normal,
            tokenHandler: { token in
                // no op
            },
            resultHandler: { result in
                XCTAssertEqual(result, ["One"])
                exp.fulfill()
            }
        )
        
        task.start()
        waitForExpectations(timeout: 5)
    }
    
    func test_executesAMultiStepTask() {
        
        let exp = expectation(description: #function)
        let utilityQueue = OperationQueue()
        
        let task = AsyncTaskOperation<[String]>(
            task: { finish in
                let accumulator = TestAccumulator()
                let one = BlockOperation {
                    accumulator.strings.append("One")
                }
                let two = BlockOperation {
                    accumulator.strings.append("Two")
                }
                let three = BlockOperation {
                    accumulator.strings.append("Three")
                }
                let finish = BlockOperation {
                    finish(accumulator.strings)
                }
                two.addDependency(one)
                three.addDependency(two)
                finish.addDependency(three)
                utilityQueue.addOperations([one, two, three, finish], waitUntilFinished: false)
            },
            cancellation: {
                utilityQueue.cancelAllOperations()
            },
            preferredPriority: .normal,
            tokenHandler: { token in
                // no op
            },
            resultHandler: { result in
                XCTAssertEqual(result, ["One", "Two", "Three"])
                exp.fulfill()
            }
        )
        
        task.start()
        waitForExpectations(timeout: 5)
    }
    
    // MARK: Result Handlers
    
    func test_invokesAllResultHandlers() {
        
        let exp = expectation(description: #function)
        
        let task = AsyncTaskOperation<[String]>(
            task: { finish in
                let accumulator = TestAccumulator()
                accumulator.strings.append("One")
                finish(accumulator.strings)
            },
            cancellation: {
                // no op
            }
        )
        
        var resultCount = 0
        
        for _ in 0...9 {
            task.addRequest(
                preferredPriority: .normal,
                tokenHandler: { token in
                    // no op
                },
                resultHandler: { result in
                    XCTAssertEqual(result, ["One"])
                    resultCount += 1
                    if resultCount == 10 {
                        exp.fulfill()
                    }
                }
            )
        }
        
        task.start()
        waitForExpectations(timeout: 5)
        
    }
    
    // MARK: Cancellation
    
    func test_cancelsAfterRemovingAllRequests() {
        
        let exp = expectation(description: #function)
        
        // Create a task that takes several seconds to finish.
        
        let task = AsyncTaskOperation<[String]>(
            task: { finish in
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    let accumulator = TestAccumulator()
                    accumulator.strings.append("One")
                    finish(accumulator.strings)
                }
            },
            cancellation: {
                // The cancellation handler should be invoked after the
                // last remaining request is removed.
                exp.fulfill()
            }
        )
        
        // Add 10 requests, collecting their tokens.
        
        typealias TokenType = AsyncTaskOperation<[String]>.RequestToken
        var tokens = [TokenType]()
        for _ in 0...9 {
            task.addRequest(
                preferredPriority: .normal,
                tokenHandler: { token in
                    if let token = token {
                        tokens.append(token)
                    }
                },
                resultHandler: { result in
                    XCTFail()
                }
            )
        }
        XCTAssert(tokens.count > 0)
        
        // Start the task. Remember it takes 5 seconds to finish.
        
        task.start()
        
        // Immediately cancel all requests.
        
        tokens.forEach {
            task.cancelRequest(with: $0)
        }
        
        // Wait 10 seconds to be sure there's plenty of time to test for the
        // cancellation.
        
        waitForExpectations(timeout: 10)
        
    }
    
    // MARK: Request Tokens
    
    func test_returnsATokenFromTheAdvancedInitializer() {
        
        let task = AsyncTaskOperation<[String]>(
            task: { finish in
                let accumulator = TestAccumulator()
                accumulator.strings.append("One")
                finish(accumulator.strings)
            },
            cancellation: {
                // no op
            },
            preferredPriority: .normal,
            tokenHandler: { token in
                XCTAssertNotNil(token)
            },
            resultHandler: { result in
                // no op
            }
        )
        
        task.start()
    }
    
    func test_returnsATokenWhenAddingTheFirstRequest() {
        
        let task = AsyncTaskOperation<[String]>(
            task: { finish in
                let accumulator = TestAccumulator()
                accumulator.strings.append("One")
                finish(accumulator.strings)
            },
            cancellation: {
                // no op
            }
        )
        
        task.addRequest(
            preferredPriority: .normal,
            tokenHandler: { (token) in
                XCTAssertNotNil(token)
            },
            resultHandler: { (result) in
                // no op
            }
        )
        
        task.start()
    }
    
    func test_returnsTokensWhenAddingAdditionalRequests() {
        
        let task = AsyncTaskOperation<[String]>(
            task: { finish in
                let accumulator = TestAccumulator()
                accumulator.strings.append("One")
                finish(accumulator.strings)
            },
            cancellation: {
                // no op
            }
        )
        
        for _ in 0...9 {
            task.addRequest(
                preferredPriority: .normal,
                tokenHandler: { (token) in
                    XCTAssertNotNil(token)
                },
                resultHandler: { (result) in
                    // no op
                }
            )
        }
        
        task.start()
    }
    
    func test_returnsNoTokenWhenTheTaskIsCancelled() {
        
        let task = AsyncTaskOperation<[String]>(
            task: { finish in
                let accumulator = TestAccumulator()
                accumulator.strings.append("One")
                finish(accumulator.strings)
            },
            cancellation: {
                // no op
            }
        )
        
        task.cancel()
        
        task.addRequest(
            preferredPriority: .normal,
            tokenHandler: { (token) in
                XCTAssertNil(token)
            },
            resultHandler: { (result) in
                XCTFail("The result handler should not be invoked.")
            }
        )
    }
    
    func test_returnsNoTokenWhenTheTaskIsFinished() {
        
        let exp = expectation(description: #function)
        
        let task = AsyncTaskOperation<[String]>(
            task: { finish in
                let accumulator = TestAccumulator()
                accumulator.strings.append("One")
                finish(accumulator.strings)
            },
            cancellation: {
                // no op
            }
        )
        
        task.addRequest(
            preferredPriority: .normal,
            tokenHandler: { (token) in
                XCTAssertNotNil(token)
            },
            resultHandler: { (result) in
                task.addRequest(
                    preferredPriority: .normal,
                    tokenHandler: { (token) in
                        XCTAssertNil(token)
                        exp.fulfill()
                    },
                    resultHandler: { (result) in
                        XCTFail("The result handler should not be invoked.")
                    }
                )
            }
        )
        
        task.start()
        waitForExpectations(timeout: 5)
    }
    
    func test_returnsATokenSynchronously_simpleInit() {
        
        var token: AsyncTaskOperation<[String]>.RequestToken? = nil
        
        let task = AsyncTaskOperation<[String]>(
            task: { finish in
                let accumulator = TestAccumulator()
                accumulator.strings.append("One")
                finish(accumulator.strings)
            },
            cancellation: {
                // no op
            }
        )
        
        task.addRequest(
            preferredPriority: .normal,
            tokenHandler: { t in
                token = t
            },
            resultHandler: { (result) in
                // no op
            }
        )
        
        XCTAssertNotNil(token)
    }
    
    func test_returnsATokenSynchronously_advancedInit() {
        
        var token: AsyncTaskOperation<[String]>.RequestToken? = nil
        
        _ = AsyncTaskOperation<[String]>(
            task: { finish in
                let accumulator = TestAccumulator()
                accumulator.strings.append("One")
                finish(accumulator.strings)
            },
            cancellation: {
                // no op
            },
            preferredPriority: .normal,
            tokenHandler: { t in
                token = t
            },
            resultHandler: { result in
                // no op
            }
        )
        
        XCTAssertNotNil(token)
    }
    
}

class AsyncTaskQueueTests: XCTestCase {
    
    func test_executesATask() {
        let exp = expectation(description: #function)
        let queue = AsyncTaskQueue<String, [String]>()
        queue.enqueue(
            task: { (finish) in
                finish(["One"])
            },
            taskId: "abc",
            cancellation: {
                // no op
            },
            preferredPriority: .normal,
            tokenHandler: { (token) in
                // no op
            },
            resultHandler: { (results) in
                XCTAssertEqual(["One"], results)
                exp.fulfill()
            }
        )
        waitForExpectations(timeout: 5)
    }
    
    func test_executesATaskOnlyOncePerTaskId() {
        
        let exp = expectation(description: #function)
        let queue = AsyncTaskQueue<String, [String]>()
        var taskAccumulator = [String]()
        var resultAccumulator = 0
        
        for _ in 0...9 {
            queue.enqueue(
                task: { (finish) in
                    taskAccumulator.append("One")
                    finish(taskAccumulator)
                },
                taskId: "abc",
                cancellation: {
                    // no op
                },
                preferredPriority: .normal,
                tokenHandler: { (token) in
                    // no op
                },
                resultHandler: { (results) in
                    XCTAssertEqual(["One"], results)
                    resultAccumulator += 1
                    if resultAccumulator == 10 {
                        exp.fulfill()
                    }
                }
            )
        }
        
        waitForExpectations(timeout: 5)
    }
    
}

class HeadRequestOperationTests: XCTestCase {
    
    func test_httpRequest() {
        
        let exp = expectation(description: #function)
        let requestOperation = HeadRequestOperation( url: URL(string: "http://www.baidu.com")!) { (result) in
            switch(result) {
                case .success(let response):
                    NSLog("\(#function) -- success: \(response)")
                    break
                case .error(let response, let error):
                    NSLog("\(#function) -- fail: \(response?.description) \n===\n\(error?.localizedDescription)")
                    break
                    
            }
            exp.fulfill()
        }
       
        let queue = OperationQueue()
        queue.addOperation(requestOperation)
        
        waitForExpectations(timeout: 10)
    }
}

/// Contrived example class that makes a HEAD request for a given URL. Its a
/// concrete subclass of AsyncOperation, which makes it easy to chain it
/// together with other (NS)Operations via standard dependencies:
///
///     let head = HeadRequestOperation(url: u) { result in
///         switch (result) {...}
///     }
///     let finish = BlockOperation {...}
///     finish.addDependency(head)
///
class HeadRequestOperation: AsyncOperation {
    
    enum Result {
        case success(HTTPURLResponse)
        case error(HTTPURLResponse?, Error?)
    }
    
    let url: URL
    private var result: Result = .error(nil, nil)
    
    init(url: URL, resultHandler: @escaping (Result) -> Void) {
        self.url = url
        super.init()
        addCompletionHandler { [weak self] in
            let result = self?.result ?? .error(nil, nil)
            resultHandler(result)
        }
    }
    
    override func execute(finish: @escaping () -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            let httpResponse = (response as? HTTPURLResponse)
            if let r = httpResponse, error == nil {
                self?.result = .success(r)
            } else {
                self?.result = .error(httpResponse, error)
            }
            finish()
        }
        task.resume()
    }
    
}

