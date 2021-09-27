//
//  CGFloat_Extensions.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/22.
//

import Foundation
import CoreGraphics


public protocol AbsoluteValueProtocol {
    associatedtype T
    var absoluteValue: T {
        get
    }
}


extension Int8: AbsoluteValueProtocol {
    public typealias T = Int8
    
    public var absoluteValue: Int8 {
        return abs(self)
    }
}

extension Int16: AbsoluteValueProtocol {
    public typealias T = Int16
    
    public var absoluteValue: Int16 {
        return abs(self)
    }
}


extension Int32: AbsoluteValueProtocol {
    public typealias T = Int32
    
    public var absoluteValue: Int32 {
        return abs(self)
    }
}


extension Int64: AbsoluteValueProtocol {
    public typealias T = Int64
    
    public var absoluteValue: Int64 {
        return abs(self)
    }
}

extension Int: AbsoluteValueProtocol {
    public typealias T = Int
    
    public var absoluteValue: Int {
        return abs(self)
    }
}

extension Float: AbsoluteValueProtocol {
    public typealias T = Float
    
    public var absoluteValue: Float {
        return abs(self)
    }
    
}

extension CGFloat: AbsoluteValueProtocol {
    public typealias T = CGFloat
    
    public var absoluteValue: CGFloat {
        return abs(self)
    }
    
}

extension Double: AbsoluteValueProtocol {
    public typealias T = Double
    
    public var absoluteValue: Double {
        return abs(self)
    }
    
}



