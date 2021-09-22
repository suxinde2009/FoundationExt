//
//  Random.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/22.
//

import Foundation



public extension Int {
    
    var random: Int {
        return Int(arc4random())%self
    }
    
    static func random(in intValue: Int) -> Int {
        return intValue.random
    }
    
}



extension Range where Bound: FixedWidthInteger {
    
    var random: Bound { .random(in: self) }
    
    func random(_ n: Int) -> [Bound] { (0..<n).map { _ in random } }
    
}


extension ClosedRange where Bound: FixedWidthInteger  {
    
    var random: Bound { .random(in: self) }
    
    func random(_ n: Int) -> [Bound] { (0..<n).map { _ in random }
        
    }
    
}
