//
//  Dictionary_Extensions.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/22.
//

import Foundation


public extension Dictionary {
    
    /// Check if the `Dictionary` has the specified key
    /// - Parameter key: the specified key
    /// - Returns: If has, returns true, otherwise, false.
    func has(key: Key) -> Bool {
        return index(forKey: key) != nil
    }

    
    
    /// Remove a sequence of value with specified key sequence
    /// - Parameter keys: the specified key sequence
    mutating func removeAll<S: Sequence>(keys: S) where S.Element == Key {
        keys.forEach { removeValue(forKey: $0) }
    }
    
    
    /// Returns JSON data from the current `Dictionary` instance.
    /// - Parameter prettify: If false, it will generate the most compact possible JSON representation, otherwise, it will generate more readable JSON representation. Default options is `false`.
    /// - Returns: Returns the generated JSON `Data` instance.
    func toData(prettify: Bool = false) -> Data? {
        guard JSONSerialization.isValidJSONObject(self) else {
            return nil
        }
        let options = (prettify == true) ?
            JSONSerialization.WritingOptions.prettyPrinted :
            JSONSerialization.WritingOptions()
        
        return try? JSONSerialization.data(withJSONObject: self, options: options)
    }
    
    
    /// Returns JSON String from the current `Dictionary` instance.
    /// - Parameter prettify: If false, it will generate the most compact possible JSON representation, otherwise, it will generate more readable JSON representation. Default options is `false`.
    /// - Returns: Returns the generated JSON `String` instance.
    func toJson(prettify: Bool = false) -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        
        let options = (prettify == true) ?
            JSONSerialization.WritingOptions.prettyPrinted :
            JSONSerialization.WritingOptions()
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: options) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}

