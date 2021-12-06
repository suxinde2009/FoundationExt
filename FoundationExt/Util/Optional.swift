//
//  Optional.swift
//  FoundationExt
//
//  Created by ak on 2021/12/6.
//

import Foundation

public protocol OptionalRepresentable {
    associatedtype WrappedType

    static var `nil`: Self {get}
}

extension Optional: OptionalRepresentable {
    public static var `nil`: Wrapped? {
        return nil
    }

    public typealias WrappedType = Wrapped
}
