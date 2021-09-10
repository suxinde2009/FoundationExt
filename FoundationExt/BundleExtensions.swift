//
//  BundleExtensions.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/1.
//

import Foundation

public extension Bundle {
    
    func path(for resourceFile: String) -> String? {
        return self.path(forResource: resourceFile, ofType: "")
    }
    
}
