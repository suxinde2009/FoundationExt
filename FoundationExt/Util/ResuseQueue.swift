//
//  ResuseQueue.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/10/16.
//

import Foundation
import UIKit

public protocol Resuable: class {
    var canReuse: Bool { get }
    func prepareForReuse()
}

extension Resuable {
    public func prepareForReuse() {}
}

extension Resuable where Self: UIView {
    public var canReuse: Bool {
        return superview == nil
    }
}


public struct ResuseQueue<E: Resuable> {

    private var queue: [String: [E]] = [:]
    
    func dequeue(with identifier: String) -> E? {
        guard let elements = queue[identifier] else { return nil }
        
        for element in elements where element.canReuse {
            return element
        }
        return nil
    }
    
    mutating func append(_ element: E, for identifier: String) {
        if queue[identifier] == nil {
            queue[identifier] = []
        }
        
        queue[identifier]?.append(element)
    }
    
}
