
#if canImport(Combine)
import Foundation
import Combine

@available(watchOSApplicationExtension 6.0, *)
@available(tvOS 13.0, *)
@available(OSX 10.15, *)
@available(iOS 13.0, *)
@usableFromInline
enum RelayState {
    
    case waiting
    
    case relaying(Subscription)
    
    case completed
}

@available(watchOSApplicationExtension 6.0, *)
@available(tvOS 13.0, *)
@available(OSX 10.15, *)
@available(iOS 13.0, *)
extension RelayState {
    
    @inlinable
    var isWaiting: Bool {
        switch self {
        case .waiting:      return true
        default:            return false
        }
    }
    
    @inlinable
    var isRelaying: Bool {
        switch self {
        case .relaying:     return true
        default:            return false
        }
    }
    
    @inlinable
    var isCompleted: Bool {
        switch self {
        case .completed:         return true
        default:            return false
        }
    }
    
    @inlinable
    var subscription: Subscription? {
        switch self {
        case .relaying(let s):  return s
        default:                return nil
        }
    }
}

@available(watchOSApplicationExtension 6.0, *)
@available(tvOS 13.0, *)
@available(OSX 10.15, *)
@available(iOS 13.0, *)
extension RelayState {
    
    func preconditionValue(file: StaticString = #file, line: UInt = #line) {
        if self.isWaiting {
            fatalError("Received value before receiving subscription", file: file, line: line)
        }
    }
    
    func preconditionCompletion(file: StaticString = #file, line: UInt = #line) {
        if self.isWaiting {
            fatalError("Received completion before receiving subscription", file: file, line: line)
        }
    }
}

@available(watchOSApplicationExtension 6.0, *)
@available(tvOS 13.0, *)
@available(OSX 10.15, *)
@available(iOS 13.0, *)
extension RelayState {
    
    @inlinable
    mutating func relay(_ subscription: Subscription) -> Bool {
        guard self.isWaiting else { return false }
        self = .relaying(subscription)
        return true
    }
    
    @inlinable
    mutating func complete() -> Subscription? {
        defer {
            self = .completed
        }
        return self.subscription
    }
}

#endif
