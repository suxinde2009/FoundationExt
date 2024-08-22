//
//  DispathQueuePool.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/10.
//

import Foundation

///
/// DispatchQueuePool, a manager class to handle DispathQueue generating.
/// Prevents generating too much threads.
///
@objc class DispatchQueuePool: NSObject {
    
    /// Name of the DispathQueue pool
    public fileprivate(set) var name: String = ""
    fileprivate var sentinel: Int32 = 0
    fileprivate var queues: [DispatchQueue] = []
    
    fileprivate static let DispatchPoolPrefixID = "com.skyprayer.FoundationExt"
    fileprivate static let MaxQueueCountInOnePool = 32
    
    fileprivate var queue: DispatchQueue {
        get {
            var currentIndex = OSAtomicIncrement32(&sentinel)
            if currentIndex < 0 { currentIndex = -currentIndex }
            return queues[Int(currentIndex) % queues.count]
        }
    }
    
    fileprivate init(with name: String,
                     qos: DispatchQoS) {
        super.init()
        self.name = name
        
        let count = min(
            max(1,ProcessInfo.processInfo.activeProcessorCount),
            DispatchQueuePool.MaxQueueCountInOnePool
        )
        
        for i in 0..<count {
            let queue =
                DispatchQueue(
                    label: "\(name).\(i)",
                    qos: qos
                )
            queues.append(queue)
        }
    }
    
    deinit {
        queues.removeAll()
    }
}

extension DispatchQueuePool {
    
    /// Get the `userInteractive` queue pool
    public static let userInteractive =
        DispatchQueuePool(
            with: "\(DispatchPoolPrefixID).DispatchQueuePool.userInteractive",
            qos: .userInteractive
        )
        
    /// Get the `default` queue pool
    public static let `default` =
        DispatchQueuePool(
            with: "\(DispatchPoolPrefixID).DispatchQueuePool.default",
            qos: .default
        )
    
    /// Get the `userInitiated` queue pool
    public static let userInitiated =
        DispatchQueuePool(
            with: "\(DispatchPoolPrefixID).DispatchQueuePool.userInitiated",
            qos: .userInitiated
        )
    
    /// Get the `utility` queue pool
    public static let utility =
        DispatchQueuePool(
            with: "\(DispatchPoolPrefixID).DispatchQueuePool.utility",
            qos: .utility
        )
    
    /// Get the `background` queue pool
    public static let background =
        DispatchQueuePool(
            with: "\(DispatchPoolPrefixID).DispatchQueuePool.background",
            qos: .background
        )
}


extension DispatchQueuePool {
    
    /// Run specificed work on the current available queue of current `DispatchQueuePool` instance asynchronously.
    /// - Parameter work: the work specificed
    public func async(work: @escaping () -> Void) {
        queue.async(execute: work)
    }
    
    /// Run specificed work on the current available queue of current `DispatchQueuePool` instance synchronously.
    /// - Parameter work: the work specificed
    public func sync(work: @escaping () -> Void) {
        queue.sync(execute: work)
    }
}
