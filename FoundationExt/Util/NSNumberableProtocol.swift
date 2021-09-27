//
//  Numberable.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/27.
//

import Foundation
import CoreGraphics

public protocol NSNumberableProtocol {
    var asNSNumber: NSNumber {
        get
    }
}

extension Bool: NSNumberableProtocol {
    public var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension UInt: NSNumberableProtocol {
    public var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension Int: NSNumberableProtocol {
    public var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension UInt8: NSNumberableProtocol {
    public var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension Int8: NSNumberableProtocol {
    public var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension UInt16: NSNumberableProtocol {
    public var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension Int16: NSNumberableProtocol {
    public var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension UInt32: NSNumberableProtocol {
    public var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension Int32: NSNumberableProtocol {
    public var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension UInt64: NSNumberableProtocol {
    public var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension Int64: NSNumberableProtocol {
    public var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension Double: NSNumberableProtocol {
    public var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension Float: NSNumberableProtocol {
    public var asNSNumber: NSNumber {
        return NSNumber(value: self)
    }
}

extension CGFloat: NSNumberableProtocol {
    public var asNSNumber: NSNumber {
        return NSNumber(value: Float(self))
    }
}
