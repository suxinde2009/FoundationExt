//
//  DispatchQueue+Extensions.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/27.
//

import Foundation

public extension DispatchQueue {
    private static var _onceTracker = [String]()
    
    class func dispatchOnce(file: String = #file,
                            function: String = #function,
                            line: Int = #line,
                            block:() -> Void) {
        let token = file + ":" + function + ":" + String(line)
        dispatchOnce(token: token,
                     block: block)
    }
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - Parameters:
     - token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - block: Block to execute once
     */
    class func dispatchOnce(token: String,
                            block:() -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
}
