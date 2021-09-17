//
//  SimpleMemoryCache.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/17.
//

import Foundation
import UIKit


/// A simple memory cache, thread safe.
/// When recieve `UIApplication.didReceiveMemoryWarningNotification`,
/// it will clear the cache in a specified background thread.
public class SimpleMemoryCache<K: Hashable, V: Hashable>: NSObject {
    
    /// The lock which makes sure the cache is thread safe.
    private var lock = NSLock()
    
    /// The DispatchQueue which handles the disposal operations
    private var disposalQueue = DispatchQueue(label: "com.skyprayer.FoundationExt.SimpleMemoryCache.disposalQueue",
                                             qos: .background)
    
    /// Internal cache container.
    private var cache: [K:V] = [:]
    
    deinit {
        removeAll()
    }
    
    /// Construct function.
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarningNotify(_:)),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc func handleMemoryWarningNotify(_ notification: AnyObject) {
        // handle the disposal operations in a background thread, preventing stuck the main thread
        disposalQueue.async {[weak self] in
            self?.removeAll()
            
        }
    }
    
    /// Remove all the cache objects.
    public func removeAll() {
        lock.lock()
        cache.removeAll()
        lock.unlock()
    }
    
    public subscript(_ key: K) -> V? {
        get {
            lock.lock()
            let v = cache[key]
            lock.unlock()
            return v
        }
        set {
            lock.lock()
            if newValue == nil {
                cache.removeValue(forKey: key)
            } else {
                cache[key] = newValue
            }
            lock.unlock()
        }
    }
    
    
    public override var description: String {
        return "SimpleMemoryCache: { \n\(cache) \n}"
    }
}
