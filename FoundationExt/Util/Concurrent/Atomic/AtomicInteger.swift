//
//  AtomicInteger.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/13.
//

import Foundation

// Reference: https://github.com/openjdk/jdk/blob/739769c8fc4b496f08a92225a12d07414537b6c0/src/java.base/share/classes/java/util/concurrent/atomic/AtomicInteger.java

/// An int value that may be updated atomically.
public class AtomicInteger: NSObject {
    
    fileprivate var value: Int = 0
    
    fileprivate var lock = NSLock()
    
    deinit {
        lock.unlock()
    }
    
    init(integer: Int) {
        super.init()
        self.set(newValue: integer)
    }
    
    
    /// Returns the current integer value
    /// - Returns: the current integer value
    public final func get() -> Int {
        var returnValue = 0
        lock.lock()
        returnValue = value
        lock.unlock()
        return returnValue
    }
    
    /// Sets the value to newValue
    /// - Parameter newValue: the new value
    /// - Returns: true represents success, false represents failure.
    public final func set(newValue: Int)  {
        lock.lock()
        value = newValue
        lock.unlock()
    }
    
    /// Atomically increments the current value
    /// - Returns: true represents success, false represents failure.
    public final func increment() {
        lock.lock()
        
        value = value + 1
        
        lock.unlock()
    }
    
    
    /// Atomically decrements the current value
    /// - Returns: true represents success, false represents failure.
    public final func decrement()  {
        lock.lock()
        
        value = value - 1
        
        lock.unlock()
    }
    
    /// Atomically increments the current value, and return the updated value
    /// - Returns: the updated value
    @discardableResult
    public final func incrementAndGet() -> Int {
        increment()
        return get()
    }
    
    /// Atomically decrements the current value, and return the updated value
    /// - Returns: the updated value
    @discardableResult
    func decrementAndGet() -> Int {
        decrement()
        return get()
    }
   
}
