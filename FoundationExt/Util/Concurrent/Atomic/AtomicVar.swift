//
//  AtomicVar.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/10.
//

import Foundation

// Reference: https://github.com/openjdk/jdk/blob/739769c8fc4b496f08a92225a12d07414537b6c0/src/java.base/share/classes/java/util/concurrent/atomic/AtomicReference.java

/// An object reference that may be updated atomically. Can't init with `lazy`
public class AtomicVar<T>: NSObject {
  
    deinit {
        value = nil
        atomicLock.unlock()
    }
    
    
    /// Creates a new AtomicVar with the given initial value.
    /// - Parameters:
    ///   - value: the initial value
    ///   - setTimeout: timeout (in a unit of second) for set action, 0 represents no timeout, waiting forever, default timeout is 0
    ///   - getTimeout: timeout (in a unit of second) for get action, 0 represents no timeout, waiting forever, default timeout is 0
    ///   - didSetAction: action after the value has been set, default is nil
    public init(_ value: T? = nil,
                setTimeout: TimeInterval = 0,
                getTimeout: TimeInterval = 0.1,
                didSet didSetAction: ((T?) -> Void)? = nil) {
        super.init()
        self.setTimeout = setTimeout
        self.getTimeout = getTimeout
        set(value)
        self.didSetAction = didSetAction
    }
    
    
    /// Sets the value to newValue
    /// - Parameter newValue: the new value
    /// - Returns: true represents success, false represents failed
    @discardableResult
    public func set(_ newValue: T?) -> Bool {
        let isSuccess = tryLock(
            atomicLock,
            { [weak self] in
                guard let `self` = self else { return }
                self.value = newValue
            },
            timeout: setTimeout,
            timeoutAction: nil
        )
        
        guard isSuccess == true else {
            return false
        }
        didSet(newValue)
        return true
    }
    
    
    /// Acquire the value, if timeout, will return nil
    /// - Returns: value, return nil if timeout happen.
    public func get() -> T? {
        var returnValue: T? = nil
        
        tryLock(
            atomicLock,
            { [weak self] in
                guard let `self` = self else { return }
                returnValue = self.value
            },
            timeout: getTimeout,
            timeoutAction: nil
        )
        
        return returnValue
    }
    
    /// Reliable function to acquire the value, no timeout limit, will block the thread.
    /// - Returns: value
    public func ensureGet() -> T? {
        var returnValue: T? = nil
        
        tryLock(
            atomicLock,
            { [weak self] in
                guard let `self` = self else { return }
                returnValue = self.value
            },
            timeout: 0,
            timeoutAction: nil
        )
        return returnValue
    }
    
    /// Atomically updates, usally for array or dictionary.
    /// - Parameter action: update action
    /// - Returns: true represents success, false represents faliure.
    @discardableResult
    
    public func update(_ action: ((inout T?) -> Void)) -> Bool {
        
        var updatedValue: T? = nil
        
        let isSuccess = tryLock(
            atomicLock,
            { [weak self] in
                guard let `self` = self else { return }
                var value = self.value
                action(&value)
                self.value = value
                updatedValue = value
            },
            timeout: setTimeout,
            timeoutAction: nil
        )
        
        if isSuccess {
            didSet(updatedValue)
            return true
        } else {
            return false
        }
    }
    
    
    
    /// Action invoked after value has been set, the default action is nil
    private var didSetAction: ((T?) -> Void)? = nil
    
    
    /// the value locked by `atomicLock`
    private var value: T? = nil

    
    /// timeout (in a unit of second) for set action, 0 represents no timeout, waiting forever, default timeout is 0
    private(set) public var setTimeout: TimeInterval = 0
    
    /// timeout (in a unit of second) for get action, 0 represents no timeout, waiting forever, default timeout is 0
    private(set) public var getTimeout: TimeInterval = 0.1
    
    
    /// Atomic lock
    private let atomicLock = NSLock()

    
    
}

fileprivate extension AtomicVar {
    
    /// Action invoked after value has been set
    /// - Parameter value: the value which has been set
    private func didSet(_ value: T?) {
        didSetAction?(value)
    }
    
    /// Attempts to acquire a lock and immediately returns a Boolean value that indicates whether the attempt was successful.
    
    /// - Parameters:
    ///   - lock: the lock
    ///   - action: acquire action
    ///   - timeout: timeout (in a unit of second) for acquire action, 0 represents no timeout, waiting forever, default timeout is 0
    ///   - timeoutAction: action for timeout
    /// - Returns: true represents success, false represents failure
    @discardableResult
    private func tryLock(_ lock: NSLock,
                         _ action: (() -> Void),
                         timeout: TimeInterval = 0,
                         timeoutAction: (() -> Void)? = nil) -> Bool {
        
        guard timeout > 0 else {
            lock.lock()
            action()
            lock.unlock()
            return true
        }
        
        let isGetLock = lock.lock(before: Date(timeIntervalSinceNow: timeout))
        guard isGetLock == true else {
            timeoutAction?()
            return false
        }
        
        action()
        lock.unlock()
        return true
    }
}
