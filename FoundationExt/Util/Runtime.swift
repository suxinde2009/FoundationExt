//
//  Runtime.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/11.
//

import Foundation

class Runtime {
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - object: <#object description#>
    ///   - key: <#key description#>
    /// - Returns: <#description#>
    public static func getAssociatedObject<T>(_ object: Any,
                                              _ key: UnsafeRawPointer) -> T? {
        return objc_getAssociatedObject(object, key) as? T
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - object: <#object description#>
    ///   - key: <#key description#>
    ///   - value: <#value description#>
    public static func setRetainedAssociatedObject<T>(_ object: Any,
                                                      _ key: UnsafeRawPointer, _ value: T) {
        objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    
    /// <#Description#>
    /// - Parameters:
    ///   - object: <#object description#>
    ///   - key: <#key description#>
    ///   - value: <#value description#>
    public static func setAssignedAssociatedObject<T>(_ object: Any,
                                                      _ key: UnsafeRawPointer, _ value: T) {
        objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_ASSIGN)
    }
}
