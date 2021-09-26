//
//  CGRect+Extensions.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/26.
//

import Foundation
import CoreGraphics

public extension CGRect {
    
    var x: CGFloat {
        get {
            return self.origin.x
        }
        set {
            var r = self
            r.origin.x = newValue
            self = r
        }
    }
    
    var y: CGFloat {
        get {
            return self.origin.y
        }
        set {
            var r = self
            r.origin.y = newValue
            self = r
        }
    }
}
