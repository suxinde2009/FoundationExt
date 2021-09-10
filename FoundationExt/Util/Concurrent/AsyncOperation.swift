//
//  AsyncOperation.swift
//  AsyncTaskQueue
//
//  Created by SuXinDe on 2021/3/13.
//  Copyright © 2021 Skyprayer Studio. All rights reserved.
//
import Foundation


open class AsyncOperation: Operation {
    
    // MARK: Private Properties
    private let executionQueue: DispatchQueue
    private var completionHandlers = [() -> Void]()
    private var lock = NSLock()
    
    // MARK: Init / Deinit
    
    /// Designated initializer.
    public override init() {
        self.executionQueue = DispatchQueue(
            label: "com.skyprayer.asyncOperation.executionQueue",
            qos: .background
        )
        super.init()
    }
    
    // MARK: Public Methods
    public func addCompletionHandler(_ handler: @escaping () -> Void) {
        guard !isCancelled && !isFinished else {return}
        lock.lock()
        completionHandlers.append(handler)
        lock.unlock()
    }
    
    // MARK: Required Methods for Subclasses
    open func execute(finish: @escaping () -> Void) {
        assertionFailure("Subclasses must override without calling super.")
    }
    
    // MARK: NSOperation
    override open func start() {
        guard !isCancelled else {return}
        markAsExecuting()
        executionQueue.async { [weak self] in
            guard let this = self else {return}
            this.execute { [weak this] in
                DispatchQueue.main.async {
                    guard let this = this else {return}
                    guard !this.isCancelled else {return}
                    this.lock.lock()
                    let handlers = this.completionHandlers
                    this.lock.unlock()
                    handlers.forEach{$0()}
                    this.markAsFinished()
                }
            }
        }
    }
    
    override open var isAsynchronous: Bool {
        return true
    }
    
    fileprivate var _finished: Bool = false
    override open var isFinished: Bool {
        get { return _finished }
        set { _finished = newValue }
    }
    
    fileprivate var _executing: Bool = false
    override open var isExecuting: Bool {
        get { return _executing }
        set { _executing = newValue }
    }
    
}

fileprivate extension AsyncOperation {
    
    // MARK: Fileprivate
    func markAsExecuting() {
        willChangeValue(for: .isExecuting)
        _executing = true
        didChangeValue(for: .isExecuting)
    }
    
    func markAsFinished() {
        willChangeValue(for: .isExecuting)
        willChangeValue(for: .isFinished)
        _executing = false
        _finished = true
        didChangeValue(for: .isExecuting)
        didChangeValue(for: .isFinished)
    }
    
    // MARK: Private
    private func willChangeValue(for key: OperationChangeKey) {
        self.willChangeValue(forKey: key.rawValue)
    }
    
    private func didChangeValue(for key: OperationChangeKey) {
        self.didChangeValue(forKey: key.rawValue)
    }
    
    private enum OperationChangeKey: String {
        case isFinished
        case isExecuting
    }
    
}


public class AsyncBlockOperation: AsyncOperation {
    
    // MARK: Typealiases
    public typealias Finish = () -> Void
    public typealias Execution = (@escaping Finish) -> Void
    
    // MARK: Private Properties
    private let execution: Execution
    
    // MARK: Init
    public init(execution: @escaping Execution) {
        self.execution = execution
    }
    
    // MARK: AsyncOperation
    public override func execute(finish: @escaping () -> Void) {
        execution(finish)
    }
    
}


public class AsyncTaskOperation<Result>: AsyncOperation {
    
    // MARK: Typealiases
    public typealias Task = (@escaping Finish) -> Void
    public typealias Finish = (Result) -> Void
    public typealias Cancellation = () -> Void
    public typealias RequestToken = NSUUID
    public typealias ResultHandler = (Result) -> Void
    public typealias RequestTokenHandler = (RequestToken?) -> Void
    
    // MARK: Private Properties
    private let task: Task
    private let cancellation: Cancellation
    private let lock = NSLock()
    private var isCancelling = false
    private var isFinishing = false
    private var unsafeRequests = [RequestToken: Request<Result>]()
    
    // MARK: Init
    public init(task: @escaping Task,
                cancellation: @escaping Cancellation) {
        self.task = task
        self.cancellation = cancellation
    }
    
    
    public init(task: @escaping Task,
                cancellation: @escaping Cancellation,
                preferredPriority: Operation.QueuePriority,
                tokenHandler: (RequestToken) -> Void,
                resultHandler: @escaping ResultHandler) {
        
        self.task = task
        self.cancellation = cancellation
        
        super.init()
        
        addRequest(
            preferredPriority: preferredPriority,
            tokenHandler: { token in
                tokenHandler(token!)
            },
            resultHandler: resultHandler
        )
        
    }
    
    // MARK: Public Methods
    
    public func addRequest(preferredPriority: Operation.QueuePriority = .normal,
                           tokenHandler: RequestTokenHandler = {_ in},
                           resultHandler: @escaping ResultHandler) {
        
        doLocked {
            let canContinue: Bool = {
                return !isCancelled
                    && !isCancelling
                    && !isFinishing
                    && !isFinished
            }()
            if canContinue {
                let request = Request(
                    preferredPriority: preferredPriority,
                    resultHandler: resultHandler
                )
                let token = request.token
                tokenHandler(token)
                unsafeRequests[request.token] = request
                self.queuePriority = unsafeHighestPriorityAmongRequests()
            } else {
                tokenHandler(nil)
            }
        }
        
    }
    
    public func cancelRequest(with token: RequestToken) {
        
        var shouldCancelOperation = false
        
        doLocked {
            let canContinue: Bool = {
                return !isCancelled
                    && !isCancelling
                    && !isFinishing
                    && !isFinished
            }()
            if canContinue {
                if unsafeRequests[token] != nil {
                    unsafeRequests[token] = nil
                    queuePriority = unsafeHighestPriorityAmongRequests()
                    shouldCancelOperation = unsafeRequests.isEmpty
                }
            }
            
            shouldCancelOperation ? (isCancelling = true) : nil
        }
        
        
        shouldCancelOperation ? cancel() : nil
        
    }
    
    public func adjustPriorityForRequest(with token: RequestToken,
                                         preferredPriority: Operation.QueuePriority) {
        doLocked {
            unsafeRequests[token]?.preferredPriority = preferredPriority
            queuePriority = unsafeHighestPriorityAmongRequests()
        }
    }
    
    // MARK: AsyncOperation
    
    public override func execute(finish: @escaping () -> Void) {
        task { [weak self] (result) in
            DispatchQueue.main.async {
                guard let this = self else {return}
                var handlers: [ResultHandler]!
                this.doLocked {
                    this.isFinishing = true
                    handlers = this.unsafeRequests.map { $0.1.resultHandler }
                }
                handlers.forEach { $0(result) }
                finish()
            }
        }
    }
    
    // MARK: Operation
    public override func cancel() {
        var canContinue: Bool!
        doLocked {
            canContinue = {
                return !isCancelled // don't check for isCancelling
                    && !isFinishing
                    && !isFinished
            }()
        }
        guard canContinue! else {return}
        cancellation()
        super.cancel()
    }
    
    // MARK: Private Methods
    private func unsafeHighestPriorityAmongRequests() -> Operation.QueuePriority {
        let priorities = unsafeRequests.compactMap({$0.1.preferredPriority.rawValue})
        if let max = priorities.max() {
            return Operation.QueuePriority(rawValue: max) ?? queuePriority
        } else {
            return queuePriority
        }
    }
    
    private func doLocked(block: () -> Void) {
        lock.lock()
        block()
        lock.unlock()
    }
    
}

private class Request<Result> {
    typealias ResultHandler = (Result) -> Void
    
    let token = NSUUID()
    let resultHandler: ResultHandler
    var preferredPriority: Operation.QueuePriority
    
    init(preferredPriority: Operation.QueuePriority,
         resultHandler: @escaping ResultHandler) {
        self.preferredPriority = preferredPriority
        self.resultHandler = resultHandler
    }
    
}
