//
//  ThreadSafeCollectionTests.swift
//  FoundationExtTests
//
//  Created by SuXinDe on 2021/9/18.
//

import XCTest
@testable import FoundationExt

class ConcurrentArrayTests: XCTestCase {
    
    func testAddObjectt() {
        let array = ConcurrentArray<String>()
        let input = "zero"
        
        array.append(input)
        assert(input == array[0])
    }
    
    func testConcurrent() {
        let array = ConcurrentArray<String>()
        let input = ["zero", "one", "two", "three", "four"]
        
        let dispathGroup = DispatchGroup()
        
        DispatchQueue.global().async(group: dispathGroup, execute: DispatchWorkItem {
            array.append(input[0])
        })
        
        DispatchQueue.global().async(group: dispathGroup, execute: DispatchWorkItem {
            array.append(input[1])
        })
        
        DispatchQueue.global().async(group: dispathGroup, execute: DispatchWorkItem {
            array.append(input[2])
        })
        
        DispatchQueue.global().async(group: dispathGroup, execute: DispatchWorkItem {
            array.append(input[3])
        })
        
        DispatchQueue.global().async(group: dispathGroup, execute: DispatchWorkItem {
            array.append(input[4])
        })
        
        dispathGroup.wait()
        
        assert(array.count == 5)
        
        for i in 0..<input.count {
            assert(array.contains(input[i]) == true)
        }
    }
    
}

class ConcurrentDictionaryTests: XCTestCase {
    
    func testConcurrent() {
        let dictionary = ConcurrentDictionary<Int,String>()
        let input = [0: "zero", 1: "one", 2: "two", 3: "three", 4: "four"]
        
        let dispathGroup = DispatchGroup()
        
        DispatchQueue.global().async(group: dispathGroup, execute: DispatchWorkItem {
            dictionary[0] = input[0]
        })
        
        DispatchQueue.global().async(group: dispathGroup, execute: DispatchWorkItem {
            dictionary[1] = input[1]
        })
        
        DispatchQueue.global().async(group: dispathGroup, execute: DispatchWorkItem {
            dictionary[2] = input[2]
        })
        
        DispatchQueue.global().async(group: dispathGroup, execute: DispatchWorkItem {
            dictionary[3] = input[3]
        })
        
        DispatchQueue.global().async(group: dispathGroup, execute: DispatchWorkItem {
            dictionary[4] = input[4]
        })
        
        dispathGroup.wait()
        
        assert(dictionary.count == 5)
        
        for key in input.keys {
            let value = input[key]
            assert(dictionary[key] == value)
        }
    }
    
}
