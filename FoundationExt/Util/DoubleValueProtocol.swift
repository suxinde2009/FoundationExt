//
//  DoubleValueProtocol.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/25.
//

import Foundation
import CoreGraphics

public protocol DoubleValueProtocol {
    var double: Double {
        get
    }
}

extension Int: DoubleValueProtocol {
    public var double: Double {
        return Double(self)
    }
}

extension Int8: DoubleValueProtocol {
    public var double: Double {
        return Double(self)
    }
}

extension Int16: DoubleValueProtocol {
    public var double: Double {
        return Double(self)
    }
}

extension Int32: DoubleValueProtocol {
    public var double: Double {
        return Double(self)
    }
}

extension Int64: DoubleValueProtocol {
    public var double: Double {
        return Double(self)
    }
}

extension CGFloat: DoubleValueProtocol {
    public var double: Double {
        return Double(self)
    }
}
