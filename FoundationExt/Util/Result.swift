//
//  Result.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/11.
//

import Foundation

// These helper methods are not public since we do not want them to be exposed or cause any conflicting.
// However, they are just wrapper of `ResultUtil` static methods.
extension Result where Failure: Error {
    
    /// Evaluates the given transform closures to create a single output value.
    ///
    /// - Parameters:
    ///   - onSuccess: A closure that transforms the success value.
    ///   - onFailure: A closure that transforms the error value.
    /// - Returns: A single `Output` value.
    func match<Output>(
        onSuccess: (Success) -> Output,
        onFailure: (Failure) -> Output) -> Output {
        
        switch self {
            case let .success(value):
                return onSuccess(value)
            case let .failure(error):
                return onFailure(error)
        }
    }
    
    func matchSuccess<Output>(
        with folder: (Success?) -> Output) -> Output {
        
        return match(
            onSuccess: { value in return folder(value) },
            onFailure: { _ in return folder(nil) }
        )
    }
    
    func matchFailure<Output>(
        with folder: (Error?) -> Output) -> Output {
        
        return match(
            onSuccess: { _ in return folder(nil) },
            onFailure: { error in return folder(error) }
        )
    }
    
    func match<Output>(
        with folder: (Success?, Error?) -> Output) -> Output {
        
        return match(
            onSuccess: { return folder($0, nil) },
            onFailure: { return folder(nil, $0) }
        )
    }
}
