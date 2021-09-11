//
//  RetryStrategy.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/11.
//

import Foundation

/// Represents decision of behavior on the current retry.
public enum RetryDecision {
    /// A retry should happen. The associated `userInfo` will be pass to the next retry in the `RetryContext` parameter.
    case retry(userInfo: Any?)
    /// There should be no more retry attempt. The image retrieving process will fail with an error.
    case stop
}

/// Defines a retry strategy can be applied to a `.retryStrategy` option.
public protocol RetryStrategy {
    
    associatedtype T
    
    /// Kingfisher calls this method if an error happens during the image retrieving process from a `KingfisherManager`.
    /// You implement this method to provide necessary logic based on the `context` parameter. Then you need to call
    /// `retryHandler` to pass the retry decision back to Kingfisher.
    ///
    /// - Parameters:
    ///   - context: The retry context containing information of current retry attempt.
    ///   - retryHandler: A block you need to call with a decision of whether the retry should happen or not.
    func retry(context: RetryContext<T>, retryHandler: @escaping (RetryDecision) -> Void)
}

public class RetryContext<T> {
    
    /// The source from which the target image should be retrieved.
    public let source: T
    
    /// The last error which caused current retry behavior.
    public let error: Error
    
    /// The retried count before current retry happens. This value is `0` if the current retry is for the first time.
    public var retriedCount: Int
    
    /// A user set value for passing any other information during the retry. If you choose to use `RetryDecision.retry`
    /// as the retry decision for `RetryStrategy.retry(context:retryHandler:)`, the associated value of
    /// `RetryDecision.retry` will be delivered to you in the next retry.
    public internal(set) var userInfo: Any? = nil
    
    init(source: T, error: Error) {
        self.source = source
        self.error = error
        self.retriedCount = 0
    }
    
    @discardableResult
    func increaseRetryCount() -> RetryContext {
        retriedCount += 1
        return self
    }
}


/// A retry strategy that guides Kingfisher to retry when a `.responseError` happens, with a specified max retry count
/// and a certain interval mechanism.
public struct DelayRetryStrategy<Type>: RetryStrategy {
    
    public typealias T = Type
    
    /// Represents the interval mechanism which used in a `DelayRetryStrategy`.
    public enum Interval {
        /// The next retry attempt should happen in fixed seconds. For example, if the associated value is 3, the
        /// attempts happens after 3 seconds after the previous decision is made.
        case seconds(TimeInterval)
        /// The next retry attempt should happen in an accumulated duration. For example, if the associated value is 3,
        /// the attempts happens with interval of 3, 6, 9, 12, ... seconds.
        case accumulated(TimeInterval)
        /// Uses a block to determine the next interval. The current retry count is given as a parameter.
        case custom(block: (_ retriedCount: Int) -> TimeInterval)
        
        func timeInterval(for retriedCount: Int) -> TimeInterval {
            let retryAfter: TimeInterval
            switch self {
                case .seconds(let interval):
                    retryAfter = interval
                case .accumulated(let interval):
                    retryAfter = Double(retriedCount + 1) * interval
                case .custom(let block):
                    retryAfter = block(retriedCount)
            }
            return retryAfter
        }
    }
    
    /// The max retry count defined for the retry strategy
    public let maxRetryCount: Int
    
    /// The retry interval mechanism defined for the retry strategy.
    public let retryInterval: Interval
    
    /// Creates a delay retry strategy.
    /// - Parameters:
    ///   - maxRetryCount: The max retry count.
    ///   - retryInterval: The retry interval mechanism. By default, `.seconds(3)` is used to provide a constant retry
    ///   interval.
    public init(maxRetryCount: Int, retryInterval: Interval = .seconds(3)) {
        self.maxRetryCount = maxRetryCount
        self.retryInterval = retryInterval
    }
    
    public func retry(context: RetryContext<Type>,
                      retryHandler: @escaping (RetryDecision) -> Void) {
        // Retry count exceeded.
        guard context.retriedCount < maxRetryCount else {
            retryHandler(.stop)
            return
        }
        
        let interval = retryInterval.timeInterval(for: context.retriedCount)
        if interval == 0 {
            retryHandler(.retry(userInfo: nil))
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                retryHandler(.retry(userInfo: nil))
            }
        }
    }
}
