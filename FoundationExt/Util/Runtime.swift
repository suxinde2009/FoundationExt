//
//  Runtime.swift
//  FoundationExt
//
//  Created by SuXinDe on 2021/9/11.
//

import Foundation

fileprivate func address(of object: Any?) -> UnsafeMutableRawPointer{
    return Unmanaged.passUnretained(object as AnyObject).toOpaque()
}

@objc public class Runtime: NSObject {
    
    public static let shared = Runtime()
    
    ///List of registered classes in runtime
    public fileprivate(set) lazy var classes : [Class_t] = {
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
        
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount: Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
        
        var classes = [AnyClass]()
        for i in 0 ..< actualClassCount {
            if let currentClass: AnyClass = allClasses[Int(i)] {
                classes.append(currentClass)
            }
        }
        allClasses.deallocate()
        
        return classes.map { Class_t($0) }
    }()
    
    
    ///List of registered classes in runtime
    public fileprivate(set) lazy var protocols : [Protocol_t] = {
        var protocols = [Protocol_t]()

        var pCount : UInt32 = 0
        guard
            let protocolList = objc_copyProtocolList(&pCount),
            pCount > 0 else
        {
            print("Total runtime protocol \(pCount)")
            return []
        }

        print("Total runtime protocol \(pCount)")

        for i in 0..<Int(pCount) {
            protocols.append(Protocol_t(protocolList[i]))
        }
        return protocols
    }()
    
    
    public fileprivate(set) lazy var frameworks : [Framework_t] = {
        var frameworks = [Framework_t]()
        var fwCount : UInt32 = 0
        let fwsList = objc_copyImageNames(&fwCount)
        defer { fwsList.deallocate()}
        
        for i in 0..<Int(fwCount) {
            let fw = fwsList.advanced(by: i).pointee
            frameworks.append(Framework_t(fw))
        }
        return frameworks
    }()
    
    
    public func subClasses(of theClass: AnyClass) -> [Class_t] {
        let theClassWrapper = Class_t(theClass.self)
        return theClassWrapper.getSubClasses()
    }
}


public extension Runtime {
    
    /// <#Description#>
    class Attribute_t {
        public fileprivate(set) var att : objc_property_attribute_t
        public fileprivate(set) lazy var name : String = {
            return Type_t.type(for: String(utf8String:att.name) ?? "").toDescrption()
        }()
        
        public fileprivate(set) lazy var rawName : String = {
            return String(utf8String:att.name) ?? ""
        }()
        
        public fileprivate(set) lazy var value : String = {
            return String(utf8String:att.value) ?? ""
        }()
        
        fileprivate init(_ att: objc_property_attribute_t) {
            self.att = att
        }
        
        public enum Type_t {
            case readOnly
            case nonAtomic
            case dynamic
            case weak
            case copy
            case retain
            case getterSelector
            case setterSelector
            case typeEncoding
            case variableName
            case unkown
            
            public static func type(for key: String) -> Type_t {
                switch key {
                    case "R": return .readOnly
                    case "N": return .nonAtomic
                    case "D": return .dynamic
                    case "W": return .weak
                    case "C": return .copy
                    case "&": return .retain
                    case "G": return .getterSelector
                    case "S": return .setterSelector
                    case "T": return .typeEncoding
                    case "V": return .variableName
                    default: return .unkown
                }
            }
            
            public func toDescrption() -> String {
                switch self {
                    case .readOnly:
                        return "readOnly"
                    case .nonAtomic:
                        return "nonAtomic"
                    case .dynamic:
                        return "dynamic"
                    case .weak:
                        return "weak"
                    case .copy:
                        return "copy"
                    case .retain:
                        return "retain"
                    case .getterSelector:
                        return "getterSelector"
                    case .setterSelector:
                        return "setterSelector"
                    case .typeEncoding:
                        return "typeEncoding"
                    case .variableName:
                        return "variableName"
                    default:
                        return "unkown"
                }
            }
        }
    }
    
    
    /// <#Description#>
    class Ivar_t {
        public fileprivate(set) var ivar : Ivar
        public fileprivate(set) lazy var name : String = {
            let ivarName = ivar_getName(ivar)
            let ivarNameStr = String(cString: ivarName!)
            return ivarNameStr
        }()
        
        public fileprivate(set) lazy var typeEncoding: String? = {
            guard let typePointer = ivar_getTypeEncoding(ivar) else { return nil }
            return String(cString: typePointer)
        }()
        
        public fileprivate(set) lazy var offset: Int = {
            return ivar_getOffset(ivar)
        }()
        
        fileprivate init(_ ivar : Ivar) {
            self.ivar = ivar
        }
    }
    
    class IMP_t {
        public fileprivate(set) var imp : IMP
        public fileprivate(set) lazy var block : Any? = {
            return imp_getBlock(imp)
        }()
        
        public init(_ imp: IMP) {
            self.imp = imp
        }
        public init(_ block: Any) {
            self.imp = imp_implementationWithBlock(block)
        }
    }
    
    class Property_t {
        public fileprivate(set) var prop : objc_property_t
        public fileprivate(set) lazy var name : String = {
            return String(cString: property_getName(prop))
        }()
        public fileprivate(set) lazy var attributesStr : String? = {
            guard let attrs = property_getAttributes(prop) else { return nil}
            return String(cString: attrs)
        }()
        public fileprivate(set) lazy var attributes : [Attribute_t] = {
            var attributes = [Attribute_t]()
            var count : UInt32 = 0
            let list = property_copyAttributeList(prop, &count)
            
            defer { list?.deallocate() }
            for i in 0..<Int(count) {
                guard let att = list?.advanced(by: 0).pointee else { continue }
                attributes.append(Attribute_t(att))
            }
            return attributes
        }()
        
        fileprivate init(_ prop : objc_property_t) {
            self.prop = prop
        }
    }
    
    class Protocol_t: Equatable {
        
        public fileprivate(set) var runtimeProtocol : Protocol
        public fileprivate(set) lazy var name : String = {
            return String(cString: protocol_getName(runtimeProtocol))
        }()
        
        public init(_ runtimeProtocol: Protocol) {
            self.runtimeProtocol = runtimeProtocol
        }
        
        public static func == (lhs: Runtime.Protocol_t,
                               rhs: Runtime.Protocol_t) -> Bool {
            return protocol_isEqual(
                lhs.runtimeProtocol,
                rhs.runtimeProtocol
            )
        }
    }
    
    class Selector_t : Equatable {
        public fileprivate(set) var sel : Selector
        public fileprivate(set) lazy var name : String = {
            return String(cString: sel_getName(sel))
        }()
        
        public fileprivate(set) lazy var isValid : Bool = {
            return sel_isMapped(sel)
        }()
        
        public init(_ sel : Selector) {
            self.sel = sel
        }
        
        public init(_ uid : UnsafePointer<Int8>) {
            self.sel = sel_getUid(uid)
        }
        public static func ==(lhs: Selector_t, rhs: Selector_t) -> Bool {
            return sel_isEqual(lhs.sel, rhs.sel)
        }
        
    }
    
    class Method_t {
        public fileprivate(set) var method : Method
        public fileprivate(set) lazy var selector : Selector_t = {
            return Selector_t(method_getName(method))
        }()
        public fileprivate(set) lazy var name : String = { return selector.name}()
        public fileprivate(set) lazy var isValid : Bool = { return selector.isValid}()
        public fileprivate(set) lazy var implementation : IMP_t = { return IMP_t(method_getImplementation(method)) }()
        
        public fileprivate(set) lazy var arguments : [String] = {
            var arguments = [String]()
            let count = method_getNumberOfArguments(method)
            for i in 0..<count {
                guard let t = method_copyArgumentType(method, i), let text = String(utf8String: t) else { continue}
                arguments.append(text)
            }
            return arguments
        }()
        
        public fileprivate(set) lazy var returnType : String = {
            return String(utf8String: method_copyReturnType(method)) ?? ""
        }()
        public fileprivate(set) lazy var typeEncoding : String = {
            guard let encoding = method_getTypeEncoding(method) else { return "" }
            return String(utf8String: encoding) ?? ""
        }()
        public init(_ method : Method) {
            self.method = method
        }
        
        
        public class Description_t {
            public fileprivate(set) var description : objc_method_description
            public fileprivate(set) lazy var name : Selector? = {
                return description.name
            }()
            public fileprivate(set) lazy var types : String? = {
                guard let t = description.types else { return nil }
                return String.init(utf8String: t)
            }()
            
            fileprivate init(_ description : objc_method_description) {
                self.description = description
            }
        }
        
    }
    
    class Object_t {}
    
    class Class_t {
        ///There's several ways to get AnyClass type
        /// 1) Inside of a certain class, to get AnyClass use  type(of: Self)
        /// 2) Use class directly: For example: UIViewController.self
        public init(_ runtimeClass : AnyClass) { self.runtimeClass = runtimeClass }
        
        ///There's several ways to get a className string
        /// NSClassFromString(....)
        /// String(describe: )
        open class func from(className: String) -> Class_t? {
            guard let cls = NSClassFromString(className) else { return nil }
            return Class_t(cls)
        }
        
        public func createInstance() -> AnyObject {
            return class_createInstance(runtimeClass, class_getInstanceSize(runtimeClass)) as AnyObject
        }
        
        
        public static func instantiate(from cls: AnyClass) -> AnyObject {
            return class_createInstance(cls, class_getInstanceSize(cls)) as AnyObject
        }
        
        public fileprivate(set) var runtimeClass : AnyClass
        
        public fileprivate(set) lazy var baseClass : Class_t? = {
            guard let cls = class_getSuperclass(runtimeClass) else { return nil}
            return Class_t(cls)
        }()
        
        public fileprivate(set) lazy var framework : Framework_t? = {
            guard let image = class_getImageName(runtimeClass) else { return nil }
            return Framework_t(image)
        }()
        
        public fileprivate(set) lazy var name : String = { return String(cString: class_getName(runtimeClass))}()
        
        public fileprivate(set) lazy var ivars : [Ivar] = {
            var ivars = [Ivar]()
            //Get a list of iVar
            var ivarCount : UInt32 = 0
            let ivarList = class_copyIvarList(runtimeClass, &ivarCount)
            defer { ivarList?.deallocate()}//Prevent memory leak
            if let ivarList = ivarList {
                for i in 0..<Int(ivarCount) {
                    let ivar = ivarList.advanced(by: i).pointee
                    ivars.append(ivar)
                }
            }
            return ivars
        }()
        
        public fileprivate(set) lazy var props : [Property_t] = {
            var props = [Property_t]()
            var propCount : UInt32 = 0
            let propList = class_copyPropertyList(runtimeClass, &propCount)
            defer { propList?.deallocate() }
            if let propList = propList {
                for i in 0..<Int(propCount) {
                    let prop = Property_t(propList.advanced(by: i).pointee)
                    props.append(prop)
                }
            }
            return props
        }()
        
        public fileprivate(set) lazy var methods : [Method_t] = {
            var methods = [Method_t]()
            var methodCount : UInt32 = 0
            let methodList = class_copyMethodList(runtimeClass, &methodCount) //This does not work for Swift Object.
            defer { methodList?.deallocate() }
            if let methodList = methodList {
                for i in 0..<Int(methodCount) {
                    let method = Method_t(methodList.advanced(by: i).pointee)
                    methods.append(method)
                }
            }
            return methods
        }()
        
        public fileprivate(set) lazy var protocols  : [Protocol_t] = {
            var procotols = [Protocol_t]()
            var protocolCount : UInt32 = 0
            let protocolList = class_copyProtocolList(runtimeClass, &protocolCount)
            if let protocolList = protocolList {
                for i in 0..<Int(protocolCount) {
                    let ptc = Protocol_t(protocolList[i])
                    procotols.append(ptc)
                }
            }
            return procotols
        }()
        
        
        public func getClassHierarchy() -> [Class_t] {
            var hierarcy = [AnyClass]()
            hierarcy.append(self.runtimeClass)
            var currentSuper: AnyClass? = class_getSuperclass(self.runtimeClass)
            while currentSuper != nil {
                hierarcy.append(currentSuper!)
                currentSuper = class_getSuperclass(currentSuper)
            }
            return hierarcy.map { Class_t($0) }
        }
        
        public func getSubClasses() -> [Class_t] {
            let expectedClassCount = objc_getClassList(nil, 0)
            let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
            
            let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
            let actualClassCount: Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
            
            let classPtr = address(of: self.runtimeClass)
            
            var result: [AnyClass] = []
            
            for i in 0 ..< actualClassCount {
                if let clazz: AnyClass = allClasses[Int(i)] {
                    guard
                        let someSuperClass = class_getSuperclass(clazz),
                        address(of: someSuperClass) == classPtr
                    else {
                        continue
                    }
                    result.append(clazz)
                }
            }
            allClasses.deallocate()
            
            return result.map { Class_t($0) }
        }
        
        
        lazy var description: String = {
            return "\(name)"
        }()
        
        @available(*, unavailable, message: "This is not available")
        public var objects : [Object_t] {
            let objects = [Object_t]()
            return objects
        }
    }
    
    class Framework_t {
        public fileprivate(set) var image : UnsafePointer<Int8>!
        public fileprivate(set) lazy var path : String = {
            return String(utf8String: image) ?? ""
        }()
        
        public fileprivate(set) lazy var url : URL! = {
            return URL(string: path)
        }()
        
        public fileprivate(set) lazy var name : String = {
            return url.lastPathComponent
        }()
        
        public init(_ image: UnsafePointer<Int8>) {
            self.image = image
        }
        
        public fileprivate(set) lazy var classes : [Class_t] = {
            var classes = [Class_t]()
            var count : UInt32 = 0
            guard let list = objc_copyClassNamesForImage(image, &count) else {
                return classes
            }
            for i in 0..<Int(count) {
                let cls = list.advanced(by: 0).pointee
                guard let aCls = NSClassFromString(String(cString: cls)) else {
                    continue
                }
                classes.append(Class_t(aCls))
            }
            return classes
        }()
        
        public func dyload() -> Bool {
            
            guard dlopen_preflight(image) else {
                //https://www.unix.com/man-page/osx/3/dlopen_preflight/
                //dlopen_preflight() returns true on if the mach-o file is compatible.  If the file is not
                //compatible, it returns false and sets an error string that can be examined with dlerror().
                if let error = dlerror() {
                    let errorStr = String.init(utf8String: error)
                    NSLog("**** dlerror ***: \(String(describing: errorStr))")
                }
                return false
            }
            
            guard let loadedFW = dlopen(image, RTLD_NOW) else {
                //Cannot load
                return false
            }
            defer { dlclose(loadedFW)}
            //let function = dlsym(loadedFW, "")
            let _ = dlsym(loadedFW, "")
            
            return true
            
        }
    }
}

public extension Runtime {
    
    class Util {
        static func valueForType(type: String) -> String {
            switch type {
                case "c" : return "Int8"
                case "s" : return "Int16"
                case "i" : return "Int32"
                case "q" : return "Int"
                case "S" : return "UInt16"
                case "I" : return "UInt32"
                case "Q" : return "UInt"
                case "B" : return "Bool"
                case "d" : return "Double"
                case "f" : return "Float"
                case "{" : return "Decimal"
                default: return type
            }
        }
    }
    
}

public extension Runtime.Method_t {
    func swapImplementation(with method: Method) {
        method_exchangeImplementations(self.method, method)
    }
    
    func swapImplementation(with lmMethod: Runtime.Method_t) {
        method_exchangeImplementations(self.method, lmMethod.method)
    }
}

public extension String {
    func toPointer(completion: @escaping (UnsafePointer<Int8>) -> ()) {
        self.withCString { (pointer) -> () in
            completion(pointer)
        }
    }
    
    // Source: https://github.com/apple/swift/blob/master/stdlib/public/core/Pointer.swift#L85-L92
    func toPointer() -> UnsafePointer<Int8> {
        let utf8 = Array(self.utf8CString)
        return _convertConstArrayToPointerArgument(utf8).1
    }
}

public extension Runtime {
    
    /// <#Description#>
    /// - Parameters:
    ///   - object: <#object description#>
    ///   - key: <#key description#>
    /// - Returns: <#description#>
    static func getAssociatedObject<T>(_ object: Any,
                                       _ key: UnsafeRawPointer) -> T? {
        return objc_getAssociatedObject(object, key) as? T
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - object: <#object description#>
    ///   - key: <#key description#>
    ///   - value: <#value description#>
    static func setRetainedAssociatedObject<T>(_ object: Any,
                                               _ key: UnsafeRawPointer, _ value: T) {
        objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - object: <#object description#>
    ///   - key: <#key description#>
    ///   - value: <#value description#>
    static func setAssignedAssociatedObject<T>(_ object: Any,
                                               _ key: UnsafeRawPointer, _ value: T) {
        objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_ASSIGN)
    }
}
