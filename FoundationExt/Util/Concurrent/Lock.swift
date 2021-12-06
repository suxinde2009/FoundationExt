//
//  Lock.swift
//  FoundationExt
//
//  Created by ak on 2021/12/6.
//

import Foundation
public protocol Lockable: class {
    func lock()
    func unlock()
}

@available(iOS 10.0, OSX 10.12, watchOS 3.0, tvOS 10.0, *)
public final class UnfairLock: Lockable {
    private var unfairLock = os_unfair_lock_s()

    public func lock() {
        os_unfair_lock_lock(&unfairLock)
    }

    public func unlock() {
        os_unfair_lock_unlock(&unfairLock)
    }
}

public final class Mutex: Lockable {
    private var mutex = pthread_mutex_t()

    init() {
        pthread_mutex_init(&mutex, nil)
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    public func lock() {
        pthread_mutex_lock(&mutex)
    }

    public func unlock() {
        pthread_mutex_unlock(&mutex)
    }
}

public final class RecursiveMutex: Lockable {
    private var mutex = pthread_mutex_t()

    init() {
        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
        pthread_mutex_init(&mutex, &attr)
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    public func lock() {
        pthread_mutex_lock(&mutex)
    }

    public func unlock() {
        pthread_mutex_unlock(&mutex)
    }
}

public final class SpinLock: Lockable {
    private let locker: Lockable

    init() {
        if #available(iOS 10.0, macOS 10.12, watchOS 3.0, tvOS 10.0, *) {
            locker = UnfairLock()
        } else {
            locker = Mutex()
        }
    }

    public func lock() {
        locker.lock()
    }

    public func unlock() {
        locker.unlock()
    }
}

public final class ConditionLock: Lockable {
    private var mutex = pthread_mutex_t()
    private var cond = pthread_cond_t()

    init() {
        pthread_mutex_init(&mutex, nil)
        pthread_cond_init(&cond, nil)
    }

    deinit {
        pthread_cond_destroy(&cond)
        pthread_mutex_destroy(&mutex)
    }

    public func lock() {
        pthread_mutex_lock(&mutex)
    }

    public func unlock() {
        pthread_mutex_unlock(&mutex)
    }

    public func wait() {
        pthread_cond_wait(&cond, &mutex)
    }

    public func wait(timeout: TimeInterval) {
        let integerPart = Int(timeout.nextDown)
        let fractionalPart = timeout - Double(integerPart)
        var ts = timespec(tv_sec: integerPart, tv_nsec: Int(fractionalPart * 1000000000))

        pthread_cond_timedwait_relative_np(&cond, &mutex, &ts)
    }

    public func signal() {
        pthread_cond_signal(&cond)
    }
}

public extension DispatchQueue {
    static private let spin = SpinLock()
    static private var tracker: Set<String> = []

    static func once(name: String, _ block: () -> Void) {
        spin.lock(); defer { spin.unlock() }
        guard !tracker.contains(name) else {
            return
        }
        block()
        tracker.insert(name)
    }
}
