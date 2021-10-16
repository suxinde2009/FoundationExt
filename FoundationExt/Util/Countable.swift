//
//  Countable.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/10/16.
//

import Foundation

enum Threshold {
    case `in`, above, below
}

protocol Countable {
    var count: Int { get }
    
    func `repeat`(_ value: Int) -> Int
    func threshold(with value: Int) -> Threshold
}

extension Dictionary: Countable {}
extension Array: Countable {}

extension Countable {
    func `repeat`(_ x: Int) -> Int {
        guard count != 0 && (x < 0 || x >= count) else {
            return x
        }
        
        var value = x
        while value < 0 {
            value += count
        }
        return value % count
    }
    
    func threshold(with value: Int) -> Threshold {
        switch value {
            case (let s) where s < 0:
                return .below
            case (let s) where s >= count:
                return .above
            default:
                return .in
        }
    }
}
