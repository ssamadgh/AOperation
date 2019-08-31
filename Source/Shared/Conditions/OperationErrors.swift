/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This file defines the error codes and convenience functions for interacting with AOperation-related errors.
 */

import Foundation

public extension Error {
    
    func map<T>(to mapHandler: (Self) -> T) -> T where T: Error {
        return mapHandler(self)
    }
    
}

public protocol Mappable {
    func map<T>(to type: T.Type) -> T?
}

public extension Mappable {
    
    func map<T>(to type: T.Type) -> T? {
        return nil
    }
    
}


extension AOperationError: Mappable {
	
	public enum State: Int {
		case conditionFailed
		case executionFailed
	}

	public struct Info: RawRepresentable, Hashable {
		
		public var rawValue: String
		
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		public static let key = Info(rawValue: "key")
        public static let errorCode = Info(rawValue: "errorCode")
		public static let reason = Info(rawValue: "reason")
		public static let localizedDescription = Info(rawValue: "localizedDescription")
	}
	
}

public struct AOperationError: LocalizedError, Equatable {
		
	public let state: State
	public let info: [Info : Any?]?
	
	private init(state: State, info: [Info : Any?]?) {
		self.state = state
		self.info = info
	}
	
	public static func executionFailed(with info: [Info : Any?]?) -> AOperationError {
		return AOperationError(state: .executionFailed, info: info)
	}
	
	public static func conditionFailed(with info: [Info : Any?]?) -> AOperationError {
		return AOperationError(state: .conditionFailed, info: info)
	}

}


public func == (lhs: AOperationError, rhs: AOperationError) -> Bool {
	var result = true
	
	result = lhs.state == rhs.state
	
	if let lkey = lhs.info?[.key] as? String, let rkey = lhs.info?[.key] as? String {
		result = lkey == rkey
	}

	return result
}


/*

extension NSError {
    public convenience init(code: AOperationError.Code, userInfo: [String: Any]? = nil) {
        self.init(domain: AOperationError.domain, code: code.rawValue, userInfo: userInfo)
    }
}

// This makes it easy to compare an `NSError.code` to an `OperationErrorCode`.
func ==(lhs: Int, rhs: AOperationError.Code) -> Bool {
    return lhs == rhs.rawValue
}

func ==(lhs: AOperationError.Code, rhs: Int) -> Bool {
    return lhs.rawValue == rhs
}

//extension Error {
//
//	init(code: OperationErrorCode, userInfo: [String: Any]? = nil) {
//		self.init(domain: OperationErrorDomain, code: code.rawValue, userInfo: userInfo)
//	}
//
//}

*/
