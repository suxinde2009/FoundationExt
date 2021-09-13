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
    
    fileprivate var value: AtomicVar<Int> = AtomicVar<Int>(0)
    
    init(integer: Int) {
        super.init()
        value = AtomicVar<Int>(integer)
    }
    
    
    /// Returns the current integer value
    /// - Returns: the current integer value
    public final func get() -> Int {
        return value.get() ?? 0
    }
    
    /// Sets the value to newValue
    /// - Parameter newValue: the new value
    /// - Returns: true represents success, false represents failure.
    @discardableResult
    public final func set(newValue: Int) -> Bool {
        return value.set(newValue)
    }
    
    /// Atomically increments the current value
    /// - Returns: true represents success, false represents failure.
    @discardableResult
    public final func increment() -> Bool {
        let intValue = value.get() ?? 0
        return value.set(intValue+1)
    }
    
    
    /// Atomically decrements the current value
    /// - Returns: true represents success, false represents failure.
    @discardableResult
    public final func decrement() -> Bool {
        let intValue = value.get() ?? 0
        return value.set(intValue-1)
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
