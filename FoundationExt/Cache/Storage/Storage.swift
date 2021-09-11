//
//  Storage.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/11.
//

import Foundation


/// Constants for some time intervals
struct TimeConstants {
    static let secondsInOneMinute = 60
    static let minutesInOneHour = 60
    static let hoursInOneDay = 24
    static let secondsInOneDay = 86_400
}

/// Represents the expiration strategy used in storage.
///
/// - never: The item never expires.
/// - seconds: The item expires after a time duration of given seconds from now.
/// - days: The item expires after a time duration of given days from now.
/// - date: The item expires after a given date.
public enum StorageExpiration {
    /// The item never expires.
    case never
    /// The item expires after a time duration of given seconds from now.
    case seconds(TimeInterval)
    /// The item expires after a time duration of given days from now.
    case days(Int)
    /// The item expires after a given date.
    case date(Date)
    /// Indicates the item is already expired. Use this to skip cache.
    case expired
    
    func estimatedExpirationSince(_ date: Date) -> Date {
        switch self {
            case .never: return .distantFuture
            case .seconds(let seconds):
                return date.addingTimeInterval(seconds)
            case .days(let days):
                let duration: TimeInterval = TimeInterval(TimeConstants.secondsInOneDay) * TimeInterval(days)
                return date.addingTimeInterval(duration)
            case .date(let ref):
                return ref
            case .expired:
                return .distantPast
        }
    }
    
    var estimatedExpirationSinceNow: Date {
        return estimatedExpirationSince(Date())
    }
    
    var isExpired: Bool {
        return timeInterval <= 0
    }
    
    var timeInterval: TimeInterval {
        switch self {
            case .never:
                return .infinity
            case .seconds(let seconds):
                return seconds
            case .days(let days):
                return TimeInterval(TimeConstants.secondsInOneDay) * TimeInterval(days)
            case .date(let ref):
                return ref.timeIntervalSinceNow
            case .expired:
                return -(.infinity)
        }
    }
}

/// Represents the expiration extending strategy used in storage to after access.
///
/// - none: The item expires after the original time, without extending after access.
/// - cacheTime: The item expiration extends by the original cache time after each access.
/// - expirationTime: The item expiration extends by the provided time after each access.
public enum ExpirationExtending {
    /// The item expires after the original time, without extending after access.
    case none
    /// The item expiration extends by the original cache time after each access.
    case cacheTime
    /// The item expiration extends by the provided time after each access.
    case expirationTime(_ expiration: StorageExpiration)
}

/// Represents types which cost in memory can be calculated.
public protocol CacheCostCalculable {
    var cacheCost: Int { get }
}

/// Represents types which can be converted to and from data.
public protocol DataTransformable {
    func toData() throws -> Data
    static func fromData(_ data: Data) throws -> Self
    static var empty: Self { get }
}


extension Date {
    var isPast: Bool {
        return isPast(referenceDate: Date())
    }
    
    var isFuture: Bool {
        return !isPast
    }
    
    func isPast(referenceDate: Date) -> Bool {
        return timeIntervalSince(referenceDate) <= 0
    }
    
    func isFuture(referenceDate: Date) -> Bool {
        return !isPast(referenceDate: referenceDate)
    }
    
    // `Date` in memory is a wrap for `TimeInterval`. But in file attribute it can only accept `Int` number.
    // By default the system will `round` it. But it is not friendly for testing purpose.
    // So we always `ceil` the value when used for file attributes.
    var fileAttributeDate: Date {
        return Date(timeIntervalSince1970: ceil(timeIntervalSince1970))
    }
}


extension Never {}

public enum StorageError: Error {
    
    case cacheError(reason: CacheErrorReason)
    
    public enum CacheErrorReason {
        
        /// Cannot create a file enumerator for a certain disk URL. Code 3001.
        /// - url: The target disk URL from which the file enumerator should be created.
        case fileEnumeratorCreationFailed(url: URL)
        
        /// Cannot get correct file contents from a file enumerator. Code 3002.
        /// - url: The target disk URL from which the content of a file enumerator should be got.
        case invalidFileEnumeratorContent(url: URL)
        
        /// The file at target URL exists, but its URL resource is unavailable. Code 3003.
        /// - error: The underlying error thrown by file manager.
        /// - key: The key used to getting the resource from cache.
        /// - url: The disk URL where the target cached file exists.
        case invalidURLResource(error: Error, key: String, url: URL)
        
        /// The file at target URL exists, but the data cannot be loaded from it. Code 3004.
        /// - url: The disk URL where the target cached file exists.
        /// - error: The underlying error which describes why this error happens.
        case cannotLoadDataFromDisk(url: URL, error: Error)
        
        /// Cannot create a folder at a given path. Code 3005.
        /// - path: The disk path where the directory creating operation fails.
        /// - error: The underlying error which describes why this error happens.
        case cannotCreateDirectory(path: String, error: Error)
        
        /// The requested image does not exist in cache. Code 3006.
        /// - key: Key of the requested file in cache.
        case fileNotExisting(key: String)
        
        /// Cannot convert an object to data for storing. Code 3007.
        /// - object: The object which needs be convert to data.
        case cannotConvertToData(object: Any, error: Error)
        
       
        /// Cannot create the cache file at a certain fileURL under a key. Code 3009.
        /// - fileURL: The url where the cache file should be created.
        /// - key: The cache key used for the cache. When caching a file through `KingfisherManager` and Kingfisher's
        ///        extension method, it is the resolved cache key based on your input `Source` and the image processors.
        /// - data: The data to be cached.
        /// - error: The underlying error originally thrown by Foundation when writing the `data` to the disk file at
        ///          `fileURL`.
        case cannotCreateCacheFile(fileURL: URL, key: String, data: Data, error: Error)
        
        /// Cannot set file attributes to a cached file. Code 3010.
        /// - filePath: The path of target cache file.
        /// - attributes: The file attribute to be set to the target file.
        /// - error: The underlying error originally thrown by Foundation when setting the `attributes` to the disk
        ///          file at `filePath`.
        case cannotSetCacheFileAttribute(filePath: String, attributes: [FileAttributeKey : Any], error: Error)
        
        /// The disk storage of cache is not ready. Code 3011.
        ///
        /// This is usually due to extremely lack of space on disk storage, and
        /// Kingfisher failed even when creating the cache folder. The disk storage will be in unusable state. Normally,
        /// ask user to free some spaces and restart the app to make the disk storage work again.
        /// - cacheURL: The intended URL which should be the storage folder.
        case diskStorageIsNotReady(cacheURL: URL)
    }
}


extension StorageError.CacheErrorReason {
    
    var errorDescription: String? {
        switch self {
            case .fileEnumeratorCreationFailed(let url):
                return "Cannot create file enumerator for URL: \(url)."
            case .invalidFileEnumeratorContent(let url):
                return "Cannot get contents from the file enumerator at URL: \(url)."
            case .invalidURLResource(let error, let key, let url):
                return "Cannot get URL resource values or data for the given URL: \(url). " +
                    "Cache key: \(key). Underlying error: \(error)"
            case .cannotLoadDataFromDisk(let url, let error):
                return "Cannot load data from disk at URL: \(url). Underlying error: \(error)"
            case .cannotCreateDirectory(let path, let error):
                return "Cannot create directory at given path: Path: \(path). Underlying error: \(error)"
            case .fileNotExisting(let key):
                return "The image is not in cache, but you requires it should only be " +
                    "from cache by enabling the `.onlyFromCache` option. Key: \(key)."
            case .cannotConvertToData(let object, let error):
                return "Cannot convert the input object to a `Data` object when storing it to disk cache. " +
                    "Object: \(object). Underlying error: \(error)"
            case .cannotCreateCacheFile(let fileURL, let key, let data, let error):
                return "Cannot create cache file at url: \(fileURL), key: \(key), data length: \(data.count). " +
                    "Underlying foundation error: \(error)."
            case .cannotSetCacheFileAttribute(let filePath, let attributes, let error):
                return "Cannot set file attribute for the cache file at path: \(filePath), attributes: \(attributes)." +
                    "Underlying foundation error: \(error)."
            case .diskStorageIsNotReady(let cacheURL):
                return "The disk storage is not ready to use yet at URL: '\(cacheURL)'. " +
                    "This is usually caused by extremely lack of disk space. Ask users to free up some space and restart the app."
        }
    }
    
    var errorCode: Int {
        switch self {
            case .fileEnumeratorCreationFailed: return 3001
            case .invalidFileEnumeratorContent: return 3002
            case .invalidURLResource: return 3003
            case .cannotLoadDataFromDisk: return 3004
            case .cannotCreateDirectory: return 3005
            case .fileNotExisting: return 3006
            case .cannotConvertToData: return 3007
            //case .cannotSerializeImage: return 3008
            case .cannotCreateCacheFile: return 3009
            case .cannotSetCacheFileAttribute: return 3010
            case .diskStorageIsNotReady: return 3011
        }
    }
}
