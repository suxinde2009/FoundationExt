//
//  DispathQueuePool.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/10.
//

import Foundation

@objc class DispatchQueuePool: NSObject {
    
    class Config {
        static let MaxQueueCount = 32
    }
    
    
    
    init(with name: String,
         queueCount: Int,
         qos: QualityOfService) {
        super.init()
    }
    
}

fileprivate struct DispatchContext {
    var name: String = ""
    var queues: [DispatchQueue] = []
    var counter: Int = 0
 
    
    mutating func dispose() {
        queues.removeAll()
    }
    
    func getQueue() {
        
    }
    
}
