//
//  AsyncTaskQueue.swift
//  AsyncTaskQueue
//
//  Created by SuXinDe on 2021/3/13.
//  Copyright © 2021 Skyprayer Studio. All rights reserved.
//

import Foundation

public class AsyncTaskQueue<TaskID: Hashable, Result> {
    
    // MARK: Public Typealiases
    public typealias Task = (@escaping Finish) -> Void
    public typealias Finish = (Result) -> Void
    public typealias Cancellation = () -> Void
    public typealias RequestToken = AsyncTaskOperation<Result>.RequestToken
    public typealias ResultHandler = (Result) -> Void
    public typealias RequestTokenHandler = (RequestToken) -> Void
    
    // MARK: Private Typealiases
    private typealias TaskOperation = AsyncTaskQueueOperation<TaskID, Result>
    
    // MARK: Private Properties
    private let operationQueue: OperationQueue
    private var taskOperations: [TaskID: TaskOperation] {
        let ops = operationQueue.operations as! [TaskOperation]
        var dictionary = [TaskID: TaskOperation]()
        ops.forEach { dictionary[$0.taskID] = $0 }
        return dictionary
    }
    
    // MARK: Init
    public init(maxConcurrentTasks: Int = OperationQueue.defaultMaxConcurrentOperationCount,
                defaultQualityOfService: QualityOfService = .background) {
        operationQueue = {
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = maxConcurrentTasks
            queue.qualityOfService = defaultQualityOfService
            return queue
        }()
    }
    
    // MARK: Public Methods
    public func enqueue(task: @escaping Task,
                        taskId: TaskID,
                        cancellation: @escaping Cancellation,
                        preferredPriority: Operation.QueuePriority = .normal,
                        tokenHandler: RequestTokenHandler,
                        resultHandler: @escaping ResultHandler) {
        
        var needToCreateNewOperation = true
        
        taskOperations[taskId]?.addRequest(
            preferredPriority: preferredPriority,
            tokenHandler: { token in
                if let token = token {
                    needToCreateNewOperation = false
                    tokenHandler(token)
                }
            },
            resultHandler: resultHandler
        )
        
        if needToCreateNewOperation {
            let operation = TaskOperation(
                taskID: taskId,
                task: task,
                cancellation: cancellation,
                preferredPriority: preferredPriority,
                tokenHandler: tokenHandler,
                resultHandler: resultHandler
            )
            operationQueue.addOperation(operation)
        }
        
    }
    
    public func cancelRequest(with token: RequestToken) {
        taskOperations.forEach { $0.1.cancelRequest(with: token) }
    }
    
    public func adjustPriorityForRequest(with token: RequestToken,
                                         preferredPriority: Operation.QueuePriority) {
        taskOperations.forEach {
            $0.1.adjustPriorityForRequest(
                with: token,
                preferredPriority: preferredPriority
            )
        }
    }
    
}

private class AsyncTaskQueueOperation<TaskID: Hashable, Result>: AsyncTaskOperation<Result> {
    
    let taskID: TaskID
    
    init(taskID: TaskID, task: @escaping Task,
         cancellation: @escaping Cancellation) {
        self.taskID = taskID
        super.init(task: task, cancellation: cancellation)
    }
    
    init(taskID: TaskID,
         task: @escaping Task,
         cancellation: @escaping Cancellation,
         preferredPriority: Operation.QueuePriority,
         tokenHandler: (RequestToken) -> Void,
         resultHandler: @escaping ResultHandler) {
        
        self.taskID = taskID
        super.init(
            task: task,
            cancellation: cancellation,
            preferredPriority: preferredPriority,
            tokenHandler: tokenHandler,
            resultHandler: resultHandler
        )
        
    }
}
