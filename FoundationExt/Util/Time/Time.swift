//
//  Time.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/14.
//

import Foundation

/// A source of time
///
/// - `.realtime` Get the amount of time since the Epoch
/// - `.monotonic` Get the amount of time since an arbitrary point
/// - `.process` Get the amount of CPU time the process has been running for
/// - `.thread` Get the amount of CPU time the thread has been running for
public struct Clock {
    public static let realtime = Clock(CLOCK_REALTIME)
    public static let monotonic = Clock(CLOCK_MONOTONIC)
    public static let process = Clock(CLOCK_PROCESS_CPUTIME_ID)
    public static let thread = Clock(CLOCK_THREAD_CPUTIME_ID)
    
    private let clockID: clockid_t
    
    private init(_ clockID: clockid_t) {
        self.clockID = clockID
    }
    
    /// Get the current time
    public func now() -> Time {
        var ts = timespec()
        clock_gettime(self.clockID, &ts)
        return Time(seconds: ts.tv_sec, nanoseconds: ts.tv_nsec)
    }
}

/// Represents a point in time relative to some fixed time in the past
public struct Deadline: Equatable, Hashable {
    public typealias Value = UInt64
    
    public static let always = Deadline(0)
    public static let never = Deadline(.max)
    
    public let uptimeNanoseconds: Value
    
    private init(_ nanoseconds: Value) {
        self.uptimeNanoseconds = nanoseconds
    }
    
    public static func now() -> Deadline {
        return Deadline(Value(Clock.monotonic.now().view.nanoseconds))
    }
    
    public static func uptimeNanoseconds(_ nanoseconds: Value) -> Deadline {
        return Deadline(nanoseconds)
    }
}

extension Deadline: Comparable {
    @inlinable
    public static func < (lhs: Deadline, rhs: Deadline) -> Bool {
        return lhs.uptimeNanoseconds < rhs.uptimeNanoseconds
    }
}

extension Deadline: CustomStringConvertible {
    @inlinable
    public var description: String {
        return self.uptimeNanoseconds.description
    }
}

extension Deadline {
    @inlinable
    public static func - (lhs: Deadline, rhs: Deadline) -> Timeout {
        if lhs >= rhs {
            return .nanoseconds(Timeout.Value(lhs.uptimeNanoseconds - rhs.uptimeNanoseconds))
        } else {
            return .nanoseconds(-Timeout.Value(rhs.uptimeNanoseconds - lhs.uptimeNanoseconds))
        }
    }
    
    @inlinable
    public static func + (lhs: Deadline, rhs: Timeout) -> Deadline {
        if rhs == .always { return .always }
        if rhs == .never { return .never}
        if rhs.nanoseconds < 0 {
            return .uptimeNanoseconds(lhs.uptimeNanoseconds - rhs.nanoseconds.magnitude)
        } else {
            return .uptimeNanoseconds(lhs.uptimeNanoseconds + rhs.nanoseconds.magnitude)
        }
    }
    
    @inlinable
    public static func - (lhs: Deadline, rhs: Timeout) -> Deadline {
        if rhs == .always { return .never }
        if rhs == .never { return .always}
        if rhs.nanoseconds < 0 {
            return .uptimeNanoseconds(lhs.uptimeNanoseconds + rhs.nanoseconds.magnitude)
        } else {
            return .uptimeNanoseconds(lhs.uptimeNanoseconds - rhs.nanoseconds.magnitude)
        }
    }
}


/// Represents a time in terms of seconds and nanoseconds
public struct Time: Equatable, Hashable {
    public static var distantPast = Time(seconds: 0, nanoseconds: 0)
    public static var distantFuture = Time(seconds: .max, nanoseconds: 0)
    
    /// Provides a view of the time with different base units
    public struct View {
        private let time: Time
        
        fileprivate init(time: Time) {
            self.time = time
        }
        
        /// The total number of seconds that the `Time` represents
        public var seconds: Int {
            return self.time.seconds
        }
        
        /// The total number of milliseconds that the `Time` represents
        public var milliseconds: Int {
            let (product, overflow1) = self.time.seconds
                .multipliedReportingOverflow(by: 1_000)
            if overflow1 { return .max }
            let (sum, overflow2) = product
                .addingReportingOverflow(self.time.nanoseconds / 1_000_000)
            if overflow2 { return .max }
            return sum
        }
        
        /// The total number of microseconds that the `Time` represents
        public var microseconds: Int {
            let (product, overflow1) = self.time.seconds
                .multipliedReportingOverflow(by: 1_000_000)
            if overflow1 { return .max }
            let (sum, overflow2) = product
                .addingReportingOverflow(self.time.nanoseconds / 1_000)
            if overflow2 { return .max }
            return sum
        }
        
        /// The total number of nanoseconds that the `Time` represents
        public var nanoseconds: Int {
            let (product, overflow1) = self.time.seconds
                .multipliedReportingOverflow(by: 1_000_000_000)
            if overflow1 { return .max }
            let (sum, overflow2) = product
                .addingReportingOverflow(self.time.nanoseconds)
            if overflow2 { return .max }
            return sum
        }
    }
    
    /// The number of seconds
    public var seconds: Int
    /// The number of nanoseconds until the next second
    public var nanoseconds: Int
    
    /// Retreive a view of the time in different units
    public var view: View {
        return View(time: self)
    }
    
    /// - Precondition: `nanoseconds >= 0`
    /// - Precondition: `nanoseconds < 1_000_000_000`
    @inlinable
    public init(seconds: Int, nanoseconds: Int) {
        precondition(nanoseconds >= 0)
        precondition(nanoseconds < 1_000_000_000)
        self.seconds = seconds
        self.nanoseconds = nanoseconds
    }
}

extension Time: Comparable {
    @inlinable
    public static func < (lhs: Time, rhs: Time) -> Bool {
        if lhs.seconds < rhs.seconds { return true }
        return lhs.seconds == rhs.seconds && lhs.nanoseconds < rhs.nanoseconds
    }
}

extension Time: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.seconds = value
        self.nanoseconds = 0
    }
}

extension Time: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        let fraction = value.truncatingRemainder(dividingBy: 1.0)
        self.seconds = Int(value)
        self.nanoseconds = Int(fraction * 1_000_000_000.0)
    }
}

extension Time: LosslessStringConvertible {
    public init?(_ description: String) {
        let parts = description.split(separator: ".")
        guard parts.count == 2 else { return nil }
        guard let seconds = Int(parts[0]) else { return nil }
        guard parts[1].count <= 9 else { return nil }
        let nano = parts[1] + String(repeating:"0", count: 9 - parts[1].count)
        guard let nanoseconds = Int(nano) else { return nil }
        self.seconds = seconds
        self.nanoseconds = nanoseconds
    }
    
    @inlinable
    public var description: String {
        let seconds = self.seconds.description
        let nanoseconds = self.nanoseconds.description
        let leadingNano = String(repeating: "0", count: 9 - nanoseconds.count)
        return seconds + "." + leadingNano + nanoseconds
    }
}

extension Time {
    @inlinable
    public static func - (lhs: Time, rhs: Time) -> Timeout {
        return .nanoseconds(Timeout.Value(lhs.view.nanoseconds - rhs.view.nanoseconds))
    }
    
    @inlinable
    public static func + (lhs: Time, rhs: Timeout) -> Time {
        if rhs == .always { return .distantPast }
        if rhs == .never { return .distantFuture }
        let (seconds, nanoseconds) = rhs.nanoseconds
            .quotientAndRemainder(dividingBy: 1_000_000_000)
        var (s, ns) = (lhs.nanoseconds + Int(nanoseconds))
            .quotientAndRemainder(dividingBy: 1_000_000_000)
        if ns < 0 {
            ns += 1_000_000_000
            s -= 1
        }
        return Time(seconds: lhs.seconds + s + Int(seconds), nanoseconds: ns)
    }
    
    @inlinable
    public static func - (lhs: Time, rhs: Timeout) -> Time {
        if rhs == .always { return .distantPast }
        if rhs == .never { return .distantFuture }
        let (seconds, nanoseconds) = rhs.nanoseconds
            .quotientAndRemainder(dividingBy: 1_000_000_000)
        var (s, ns) = (lhs.nanoseconds - Int(nanoseconds))
            .quotientAndRemainder(dividingBy: 1_000_000_000)
        if ns < 0 {
            ns += 1_000_000_000
            s -= 1
        }
        return Time(seconds: lhs.seconds + s - Int(seconds), nanoseconds: ns)
    }
}

/// Represents a time interval in nanoseconds
public struct Timeout: Equatable {
    public typealias Value = Int64
    
    public static let always = Timeout(.min)
    public static let never = Timeout(.max)
    
    public let nanoseconds: Value
    
    private init(_ nanoseconds: Value) {
        self.nanoseconds = nanoseconds
    }
    
    public static func nanoseconds(_ amount: Value) -> Timeout {
        return Timeout(amount)
    }
    
    public static func microseconds(_ amount: Value) -> Timeout {
        return Timeout(amount * 1_000)
    }
    
    public static func milliseconds(_ amount: Value) -> Timeout {
        return Timeout(amount * 1_000_000)
    }
    
    public static func seconds(_ amount: Value) -> Timeout {
        return Timeout(amount * 1_000_000_000)
    }
    
    public static func minutes(_ amount: Value) -> Timeout {
        return Timeout(amount * 60_000_000_000)
    }
    
    public static func hours(_ amount: Value) -> Timeout {
        return Timeout(amount * 3_600_000_000_000)
    }
}

extension Timeout: Comparable {
    @inlinable
    public static func < (lhs: Timeout, rhs: Timeout) -> Bool {
        return lhs.nanoseconds < rhs.nanoseconds
    }
}

extension Timeout {
    public static func + (lhs: Timeout, rhs: Timeout) -> Timeout {
        return Timeout(lhs.nanoseconds + rhs.nanoseconds)
    }
    
    public static func - (lhs: Timeout, rhs: Timeout) -> Timeout {
        return Timeout(lhs.nanoseconds - rhs.nanoseconds)
    }
    
    public static func * <T: BinaryInteger>(lhs: T, rhs: Timeout) -> Timeout {
        return Timeout(Timeout.Value(lhs) * rhs.nanoseconds)
    }
    
    public static func * <T: BinaryInteger>(lhs: Timeout, rhs: T) -> Timeout {
        return Timeout(lhs.nanoseconds * Timeout.Value(rhs))
    }
}
