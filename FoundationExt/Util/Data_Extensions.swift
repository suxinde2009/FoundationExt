//
//  Data_Extensions.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/22.
//

import Foundation


public extension Data {
    
    
    /// Get an `String` object initialized by converting given data into UTF-16 code units using a given encoding, default is `.utf8`.
    ///
    /// - Parameter encoding: The encoding used by data. For possible values, see `String.Encoding`, default is `.utf8`.
    /// - Returns: The `String` instance
    func toString(encoding: String.Encoding = .utf8) -> String? {
        return String(data: self, encoding: encoding)
    }
    
    /// Get Byte array of the given `Data' instance.
    /// - Returns: An Byte array instance
    func toBytes()->[UInt8]{
        return [UInt8](self)
    }
    
    /// Returns a Foundation object from given JSON `Data` instance.
    func toObject(options: JSONSerialization.ReadingOptions = []) throws -> Any {
        return try JSONSerialization.jsonObject(with: self, options: options)
    }
    
}
