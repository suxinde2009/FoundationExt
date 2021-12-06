//
//  Atomic.swift
//  FoundationExt
//
//  Created by ak on 2021/12/6.
//

import Foundation

import Foundation
final class Atomic<Value> {
    var raw: Value
    let spinLock = SpinLock()

    init(_ raw: Value) {
        self.raw = raw
    }

    var value: Value {
        spinLock.lock(); defer { spinLock.unlock() }
        return raw
    }

    func withValue(_ closure: (Value) -> Value) {
        spinLock.lock(); defer { spinLock.unlock() }
        raw = closure(raw)
    }

    func assign(_ newValue: Value) {
        spinLock.lock(); defer { spinLock.unlock() }
        self.raw = newValue
    }
}

extension Atomic where Value==Int {
    static func += (left: Atomic, right: Value) {
        left.withValue { (value) -> Value in
            return value + right
        }
    }

    static func -= (left: Atomic, right: Value) {
        left.withValue { (value) -> Value in
            return value - right
        }
    }

    static prefix func ++ (atomic: Atomic) -> Value {
        var newValue: Value = 0
        atomic.withValue { (value) -> Value in
            newValue = value + 1
            return newValue
        }
        return newValue
    }
}

extension Atomic where Value: Equatable {
    static func == (left: Atomic, right: Value) -> Bool {
        return left.value == right
    }
}

extension Atomic where Value: Comparable {
    static func < (left: Atomic, right: Value) -> Bool {
        return left.value < right
    }
    static func > (left: Atomic, right: Value) -> Bool {
        return left.value > right
    }
}

extension Atomic where Value: OptionalRepresentable {
    convenience init() {
        self.init(Value.`nil`)
    }
}

extension Atomic: CustomStringConvertible {
    var description: String {
        return "\(value)"
    }
}
