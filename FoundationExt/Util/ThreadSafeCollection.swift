//
//  ThreadSafeCollection.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/18.
//

import Foundation

/// An thread safe array wrapper class.
public class ThreadSafeArray<T: Hashable>: Collection {
    
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index immediately after `i`.
    public func index(after i: Int) -> Int {
        concurrentQueue.sync {
            return array.index(after: i)
        }
    }
    
    /// The position of the first element in a nonempty array.
    ///
    /// For an instance of `ThreadSafeArray`, `startIndex` is always zero. If the array
    /// is empty, `startIndex` is equal to `endIndex`.
    public var startIndex: Int {
        get {
            concurrentQueue.sync {
                return array.startIndex
            }
        }
    }
    
    /// The array's "past the end" position---that is, the position one greater
    /// than the last valid subscript argument.
    ///
    /// When you need a range that includes the last element of an array, use the
    /// half-open range operator (`..<`) with `endIndex`. The `..<` operator
    /// creates a range that doesn't include the upper bound, so it's always
    /// safe to use with `endIndex`. For example:
    ///
    ///     let numbers = ThreadSafeArray<Int>([10, 20, 30, 40, 50])
    ///     if let i = numbers.firstIndex(of: 30) {
    ///         print(numbers[i ..< numbers.endIndex])
    ///     }
    ///     // Prints "[30, 40, 50]"
    ///
    /// If the array is empty, `endIndex` is equal to `startIndex`.
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
    
    /// Construct function, create an `ThreadSafeArray` instance with an specified `Array` and return the instance.
    /// - Parameter array: the specified `Array`
    init(_ array: [T] = []) {
        self.array = array
    }
    
    /// The first element of the collection.
    ///
    /// If the collection is empty, the value of this property is `nil`.
    ///
    ///     let numbers = ThreadSafeArray<Int>([10, 20, 30, 40, 50])
    ///     if let firstNumber = numbers.first {
    ///         print(firstNumber)
    ///     }
    ///     // Prints "10"
    var first: T? {
        var result: T?
        concurrentQueue.sync { result = self.array.first }
        return result
    }
    
    /// The last element of the collection.
    ///
    /// If the collection is empty, the value of this property is `nil`.
    ///
    ///     let numbers = ThreadSafeArray<Int>([10, 20, 30, 40, 50])
    ///     if let lastNumber = numbers.last {
    ///         print(lastNumber)
    ///     }
    ///     // Prints "50"
    ///
    /// - Complexity: O(1)
    var last: T? {
        var result: T?
        concurrentQueue.sync { result = self.array.last }
        return result
    }
    
    /// The number of elements in the array.
    public var count: Int {
        var result = 0
        concurrentQueue.sync { result = self.array.count }
        return result
    }
    
    /// A Boolean value indicating whether the collection is empty.
    ///
    /// When you need to check whether your collection is empty, use the
    /// `isEmpty` property instead of checking that the `count` property is
    /// equal to zero. For collections that don't conform to
    /// `RandomAccessCollection`, accessing the `count` property iterates
    /// through the elements of the collection.
    ///
    /// - Complexity: O(1)
    public var isEmpty: Bool {
        var result = false
        concurrentQueue.sync { result = self.array.isEmpty }
        return result
    }
    
    /// A textual representation of the array and its elements.
    public var description: String {
        var result = ""
        concurrentQueue.sync { result = self.array.description }
        return result
    }
    
    /// Returns the first element of the sequence that satisfies the given
    /// predicate.
    ///
    /// The following example uses the `first(where:)` method to find the first
    /// negative number in an array of integers:
    ///
    ///     let numbers = ThreadSafeArray<Int>([3, 7, 4, -2, 9, -6, 10, 1])
    ///     if let firstNegative = numbers.first(where: { $0 < 0 }) {
    ///         print("The first negative number is \(firstNegative).")
    ///     }
    ///     // Prints "The first negative number is -2."
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as
    ///   its argument and returns a Boolean value indicating whether the
    ///   element is a match.
    /// - Returns: The first element of the sequence that satisfies `predicate`,
    ///   or `nil` if there is no element that satisfies `predicate`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
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
    
    /// Returns the first index in which an element of the collection satisfies the given predicate.
    /// - Parameter predicate: A closure that takes an element as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    /// - Returns: The index of the first element for which predicate returns true. If no elements in the collection satisfy the given predicate, returns nil.
    func index(where predicate: (T) -> Bool) -> Int? {
        var result: Int?
        concurrentQueue.sync { result = self.array.firstIndex(where: predicate) }
        return result
    }
    
    /// Returns the elements of the sequence, sorted using the given predicate as
    /// the comparison between elements.
    ///
    /// When you want to sort a sequence of elements that don't conform to the
    /// `Comparable` protocol, pass a predicate to this method that returns
    /// `true` when the first element should be ordered before the second. The
    /// elements of the resulting array are ordered according to the given
    /// predicate.
    ///
    /// In the following example, the predicate provides an ordering for an array
    /// of a custom `HTTPResponse` type. The predicate orders errors before
    /// successes and sorts the error responses by their error code.
    ///
    ///     enum HTTPResponse {
    ///         case ok
    ///         case error(Int)
    ///     }
    ///
    ///     let responses: ThreadSafeArray<HTTPResponse> = ThreadSafeArray<HTTPResponse>([.error(500), .ok, .ok, .error(404), .error(403)])
    ///     let sortedResponses = responses.sorted {
    ///         switch ($0, $1) {
    ///         // Order errors by code
    ///         case let (.error(aCode), .error(bCode)):
    ///             return aCode < bCode
    ///
    ///         // All successes are equivalent, so none is before any other
    ///         case (.ok, .ok): return false
    ///
    ///         // Order errors before successes
    ///         case (.error, .ok): return true
    ///         case (.ok, .error): return false
    ///         }
    ///     }
    ///     print(sortedResponses)
    ///     // Prints "[.error(403), .error(404), .error(500), .ok, .ok]"
    ///
    /// You also use this method to sort elements that conform to the
    /// `Comparable` protocol in descending order. To sort your sequence in
    /// descending order, pass the greater-than operator (`>`) as the
    /// `areInIncreasingOrder` parameter.
    ///
    ///     let students = ThreadSafeArray<String>(["Kofi", "Abena", "Peter", "Kweku", "Akosua"])
    ///     let descendingStudents = students.sorted(by: >)
    ///     print(descendingStudents)
    ///     // Prints "["Peter", "Kweku", "Kofi", "Akosua", "Abena"]"
    ///
    /// Calling the related `sorted()` method is equivalent to calling this
    /// method and passing the less-than operator (`<`) as the predicate.
    ///
    ///     print(students.sorted())
    ///     // Prints "["Abena", "Akosua", "Kofi", "Kweku", "Peter"]"
    ///     print(students.sorted(by: <))
    ///     // Prints "["Abena", "Akosua", "Kofi", "Kweku", "Peter"]"
    ///
    /// The predicate must be a *strict weak ordering* over the elements. That
    /// is, for any elements `a`, `b`, and `c`, the following conditions must
    /// hold:
    ///
    /// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
    /// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are
    ///   both `true`, then `areInIncreasingOrder(a, c)` is also `true`.
    ///   (Transitive comparability)
    /// - Two elements are *incomparable* if neither is ordered before the other
    ///   according to the predicate. If `a` and `b` are incomparable, and `b`
    ///   and `c` are incomparable, then `a` and `c` are also incomparable.
    ///   (Transitive incomparability)
    ///
    /// The sorting algorithm is not guaranteed to be stable. A stable sort
    /// preserves the relative order of elements for which
    /// `areInIncreasingOrder` does not establish an order.
    ///
    /// - Parameter areInIncreasingOrder: A predicate that returns `true` if its
    ///   first argument should be ordered before its second argument;
    ///   otherwise, `false`.
    /// - Returns: A sorted array of the sequence's elements.
    ///
    /// - Complexity: O(*n* log *n*), where *n* is the length of the sequence.
    func sorted(by areInIncreasingOrder: (T, T) -> Bool) -> [T] {
        var result = [T]()
        concurrentQueue.sync { result = self.array.sorted(by: areInIncreasingOrder) }
        return result
    }
    
    /// Returns an array containing the non-nil results of calling the given transformation with each element of this sequence.
    /// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
    /// - Returns: An array of the non-nil results of calling transform with each element of the sequence.
    func flatMap<ElementOfResult>(_ transform: (T) -> ElementOfResult?) -> [ElementOfResult] {
        var result = [ElementOfResult]()
        concurrentQueue.sync { result = self.array.compactMap(transform) }
        return result
    }
    
    /// Calls the given closure on each element in the sequence in the same order as a for-in loop.
    /// - Parameter body: A closure that takes an element of the sequence as a parameter.
    func forEach(_ body: (T) -> Void) {
        concurrentQueue.sync { self.array.forEach(body) }
    }
    
    /// Returns a Boolean value indicating whether the sequence contains an element that satisfies the given predicate.
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    /// - Returns: true if the sequence contains an element that satisfies predicate; otherwise, false.
    func contains(where predicate: (T) -> Bool) -> Bool {
        var result = false
        concurrentQueue.sync { result = self.array.contains(where: predicate) }
        return result
    }
    
    /// Adds an element to the end of the collection.
    /// - Parameter element: The element to append to the collection.
    func append( _ element: T) {
        concurrentQueue.async(flags: .barrier) {
            self.array.append(element)
        }
    }
    
    /// Adds an elements to the end of the collection.
    /// - Parameter element: The elements to append to the collection.
    func append( _ elements: [T]) {
        concurrentQueue.async(flags: .barrier) {
            self.array += elements
        }
    }
    
    /// Inserts a new element at the specified position.
    ///
    /// The new element is inserted before the element currently at the specified
    /// index. If you pass the array's `endIndex` property as the `index`
    /// parameter, the new element is appended to the array.
    ///
    ///     var numbers = ThreadSafeArray<Int>([1, 2, 3, 4, 5])
    ///     numbers.insert(100, at: 3)
    ///     numbers.insert(200, at: numbers.endIndex)
    ///
    ///     print(numbers)
    ///     // Prints "[1, 2, 3, 100, 4, 5, 200]"
    ///
    /// - Parameter element: The new element to insert into the array.
    /// - Parameter index: The position at which to insert the new element.
    ///   `index` must be a valid index of the array or equal to its `endIndex`
    ///   property.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the array. If
    ///   `i == endIndex`, this method is equivalent to `append(_:)`.
    func insert( _ element: T, at index: Int) {
        concurrentQueue.async(flags: .barrier) {
            self.array.insert(element, at: index)
        }
    }
    
    /// Remove element at specified index
    /// - Parameters:
    ///   - index: the specified index to removed
    ///   - completion: bring back the elment removed
    func remove(at index: Int, completion: ((T) -> Void)? = nil) {
        concurrentQueue.async(flags: .barrier) {
            let element = self.array.remove(at: index)
            
            DispatchQueue.main.async {
                completion?(element)
            }
        }
    }
    
    /// Remove the first element in the array which meet the predicate
    /// - Parameters:
    ///   - predicate: the predicate to meet
    ///   - completion: bring back the elment removed
    func remove(where predicate: @escaping (T) -> Bool, completion: ((T) -> Void)? = nil) {
        concurrentQueue.async(flags: .barrier) {
            guard let index = self.array.firstIndex(where: predicate) else { return }
            let element = self.array.remove(at: index)
            
            DispatchQueue.main.async {
                completion?(element)
            }
        }
    }
    
    
    /// Removes all elements from the array.
    /// - Parameter completion: bring back the elements with the main thread
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
    
    /// Append the right value to the left
    static func +=(left: inout ThreadSafeArray, right: T) {
        left.append(right)
    }
    
    /// Append the right values to the left
    static func +=(left: inout ThreadSafeArray, right: [T]) {
        left.append(right)
    }
    
    /// Append the right values to the left
    static func +=(left: inout ThreadSafeArray, right: ThreadSafeArray) {
        left += right.getInternalArray()
    }
    
    fileprivate func getInternalArray() -> [T] {
        var internalArray: [T] = []
        concurrentQueue.sync {
            internalArray = array
        }
        return internalArray
    }
    
}

public extension ThreadSafeArray where T: Equatable {
    
    /// Returns a Boolean value indicating whether the sequence contains the
    /// given element.
    ///
    /// This example checks to see whether a favorite actor is in an array
    /// storing a movie's cast.
    ///
    ///     let cast = ThreadSafeArray<String>(["Vivien", "Marlon", "Kim", "Karl"])
    ///     print(cast.contains("Marlon"))
    ///     // Prints "true"
    ///     print(cast.contains("James"))
    ///     // Prints "false"
    ///
    /// - Parameter element: The element to find in the sequence.
    /// - Returns: `true` if the element was found in the sequence; otherwise,
    ///   `false`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
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
    
    /// The position of the first element in a nonempty dictionary.
    ///
    /// If the collection is empty, `startIndex` is equal to `endIndex`.
    ///
    /// - Complexity: Amortized O(1) if the dictionary does not wrap a bridged
    ///   `NSDictionary`. If the dictionary wraps a bridged `NSDictionary`, the
    ///   performance is unspecified.
    var startIndex: Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.startIndex
        }
    }
    /// The dictionary's "past the end" position---that is, the position one
    /// greater than the last valid subscript argument.
    ///
    /// If the collection is empty, `endIndex` is equal to `startIndex`.
    ///
    /// - Complexity: Amortized O(1) if the dictionary does not wrap a bridged
    ///   `NSDictionary`; otherwise, the performance is unspecified.
    var endIndex: Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.endIndex
        }
    }
    
    /// Construct function, create an `ThreadSafeDictionary` instance with an specified `Dictionary` and return the instance.
    /// - Parameter dict: the specified `Dictionary`
    init(dict: [V: T] = [V:T]()) {
        self.dictionary = dict
    }
    
    /// Returns the position immediately after the given index.
    ///
    /// The successor of an index must be well defined. For an index `i` into a
    /// collection `c`, calling `c.index(after: i)` returns the same index every
    /// time.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
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
    
    /// Removes the given key and its associated value from the dictionary.
    ///
    /// If the key is found in the dictionary, this method returns the key's
    /// associated value. On removal, this method invalidates all indices with
    /// respect to the dictionary.
    ///
    ///     var hues = ThreadSafeDictionary<String:Int>(dict:["Heliotrope": 296, "Coral": 16, "Aquamarine": 156])
    ///     if let value = hues.removeValue(forKey: "Coral") {
    ///         print("The value \(value) was removed.")
    ///     }
    ///     // Prints "The value 16 was removed."
    ///
    /// If the key isn't found in the dictionary, `removeValue(forKey:)` returns
    /// `nil`.
    ///
    ///     if let value = hues.removeValueForKey("Cerise") {
    ///         print("The value \(value) was removed.")
    ///     } else {
    ///         print("No value found for that key.")
    ///     }
    ///     // Prints "No value found for that key.""
    ///
    /// - Parameter key: The key to remove along with its associated value.
    /// - Returns: The value that was removed, or `nil` if the key was not
    ///   present in the dictionary.
    ///
    /// - Complexity: O(*n*), where *n* is the number of key-value pairs in the
    ///   dictionary.
    func removeValue(forKey key: V) {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeValue(forKey: key)
        }
    }
    
    /// Removes all key-value pairs from the dictionary.
    ///
    /// Calling this method invalidates all indices with respect to the
    /// dictionary.
    ///
    /// - Parameter keepCapacity: Whether the dictionary should keep its
    ///   underlying buffer. If you pass `true`, the operation preserves the
    ///   buffer capacity that the collection has, otherwise the underlying
    ///   buffer is released.  The default is `false`.
    ///
    /// - Complexity: O(*n*), where *n* is the number of key-value pairs in the
    ///   dictionary.
    func removeAll() {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeAll()
        }
    }
    
}




