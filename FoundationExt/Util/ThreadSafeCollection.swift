//
//  ThreadSafeCollection.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/18.
//

import Foundation

/// An thread safe array wrapper class.
public class ThreadSafeArray<T: Hashable>: Collection {
    
    public func index(after i: Int) -> Int {
        concurrentQueue.sync {
            return array.index(after: i)
        }
    }
    
    public var startIndex: Int {
        get {
            concurrentQueue.sync {
                return array.startIndex
            }
        }
    }
    
    public var endIndex: Int {
        get {
            concurrentQueue.sync {
                return array.endIndex
            }
        }
    }
    
    
    private var array: [T]
    fileprivate let concurrentQueue =
        DispatchQueue(
            label: "Com.BigNerdCoding.SafeArray",
            attributes: .concurrent
        )
    
    init(array: [T] = []) {
        self.array = array
    }
    
    var first: T? {
        var result: T?
        concurrentQueue.sync { result = self.array.first }
        return result
    }
    
    var last: T? {
        var result: T?
        concurrentQueue.sync { result = self.array.last }
        return result
    }
    
    public var count: Int {
        var result = 0
        concurrentQueue.sync { result = self.array.count }
        return result
    }
    
    public var isEmpty: Bool {
        var result = false
        concurrentQueue.sync { result = self.array.isEmpty }
        return result
    }
    
    public var description: String {
        var result = ""
        concurrentQueue.sync { result = self.array.description }
        return result
    }
    
    func first(where predicate: (T) -> Bool) -> T? {
        var result: T?
        concurrentQueue.sync { result = self.array.first(where: predicate) }
        return result
    }
    
    func filter(_ isIncluded: (T) -> Bool) -> [T] {
        var result = [T]()
        concurrentQueue.sync { result = self.array.filter(isIncluded) }
        return result
    }
    
    func index(where predicate: (T) -> Bool) -> Int? {
        var result: Int?
        concurrentQueue.sync { result = self.array.firstIndex(where: predicate) }
        return result
    }
    
    func sorted(by areInIncreasingOrder: (T, T) -> Bool) -> [T] {
        var result = [T]()
        concurrentQueue.sync { result = self.array.sorted(by: areInIncreasingOrder) }
        return result
    }
    
    func flatMap<ElementOfResult>(_ transform: (T) -> ElementOfResult?) -> [ElementOfResult] {
        var result = [ElementOfResult]()
        concurrentQueue.sync { result = self.array.compactMap(transform) }
        return result
    }
    
    func forEach(_ body: (T) -> Void) {
        concurrentQueue.sync { self.array.forEach(body) }
    }
    
    func contains(where predicate: (T) -> Bool) -> Bool {
        var result = false
        concurrentQueue.sync { result = self.array.contains(where: predicate) }
        return result
    }
    
    func append( _ element: T) {
        concurrentQueue.async(flags: .barrier) {
            self.array.append(element)
        }
    }
    
    func append( _ elements: [T]) {
        concurrentQueue.async(flags: .barrier) {
            self.array += elements
        }
    }
    
    func insert( _ element: T, at index: Int) {
        concurrentQueue.async(flags: .barrier) {
            self.array.insert(element, at: index)
        }
    }
    
    func remove(at index: Int, completion: ((T) -> Void)? = nil) {
        concurrentQueue.async(flags: .barrier) {
            let element = self.array.remove(at: index)
            
            DispatchQueue.main.async {
                completion?(element)
            }
        }
    }
    
    func remove(where predicate: @escaping (T) -> Bool, completion: ((T) -> Void)? = nil) {
        concurrentQueue.async(flags: .barrier) {
            guard let index = self.array.firstIndex(where: predicate) else { return }
            let element = self.array.remove(at: index)
            
            DispatchQueue.main.async {
                completion?(element)
            }
        }
    }
    
    func removeAll(completion: (([T]) -> Void)? = nil) {
        concurrentQueue.async(flags: .barrier) {
            let elements = self.array
            self.array.removeAll()
            
            DispatchQueue.main.async {
                completion?(elements)
            }
        }
    }
    
    public subscript(index: Int) -> T? {
        get {
            var result: T?
            
            concurrentQueue.sync {
                guard self.array.startIndex..<self.array.endIndex ~= index else { return }
                result = self.array[index]
            }
            
            return result
        }
        set {
            guard let newValue = newValue else { return }
            
            concurrentQueue.async(flags: .barrier) {
                self.array[index] = newValue
            }
        }
    }
    
    static func +=(left: inout ThreadSafeArray, right: T) {
        left.append(right)
    }
    
    static func +=(left: inout ThreadSafeArray, right: [T]) {
        left.append(right)
    }
}

public extension ThreadSafeArray where T: Equatable {
    
    func contains(_ element: T) -> Bool {
        var result = false
        concurrentQueue.sync {
            result = self.array.contains(element)
        }
        return result
    }
}



/// A thread safe Dictionary wrapper class.
class ThreadSafeDictionary<V: Hashable,T>: Collection {

    private var dictionary: [V: T]
    private let concurrentQueue = DispatchQueue(label: "Dictionary Barrier Queue",
                                                attributes: .concurrent)
    var startIndex: Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.startIndex
        }
    }
    
    var endIndex: Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.endIndex
        }
    }
    
    init(dict: [V: T] = [V:T]()) {
        self.dictionary = dict
    }
    // this is because it is an apple protocol method
    // swiftlint:disable identifier_name
    func index(after i: Dictionary<V, T>.Index) -> Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.index(after: i)
        }
    }
    // swiftlint:enable identifier_name
    subscript(key: V) -> T? {
        set(newValue) {
            self.concurrentQueue.async(flags: .barrier) {[weak self] in
                self?.dictionary[key] = newValue
            }
        }
        get {
            self.concurrentQueue.sync {
                return self.dictionary[key]
            }
        }
    }
    
    // has implicity get
    subscript(index: Dictionary<V, T>.Index) -> Dictionary<V, T>.Element {
        self.concurrentQueue.sync {
            return self.dictionary[index]
        }
    }
    
    func removeValue(forKey key: V) {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeValue(forKey: key)
        }
    }
    
    func removeAll() {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeAll()
        }
    }
    
}




