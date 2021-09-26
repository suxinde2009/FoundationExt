//
//  Comparable+Extensions.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/26.
//

import Foundation

public extension Comparable {
    
    func clamp(
        low: Self? = nil,
        high: Self? = nil
    ) -> Self {
        
        if let high = high {
            if self > high {
                return high
            }
        }
        if let low = low {
            if self < low {
                return low
            }
        }
        return self
    }
}
