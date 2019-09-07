/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This file defines the errors and convenience functions for interacting with AOperation-related errors.
 */

import Foundation


/// Errors returned by AOperation APIs.
public struct AOperationError: LocalizedError, Equatable {
		
    /**
     The state of error emitation
     
     If state be conditionFailed, means error is belong to a condition, if state be executionFailed means error belongs to an operation.
     */
	public let state: State
    
    
    /**
     The error’s info dictionary.
     
     Use `AOperationError.Info.key` key to get the error emitter name.
     Use other keys in  dictionary to map `AOperationError` to other Errors type.
     */
	public let info: [Info : Any?]?
    
    /// Initializes an error with a given state and info dictionary.
    /// - Parameter state: The state of error emitation
    /// - Parameter info: The error’s info dictionary.
	private init(state: State, info: [Info : Any?]?) {
		self.state = state
		self.info = info
	}
    
    /// Returns an error with executionFailed state and given info.
    /// - Parameter info: The error’s info dictionary.
	public static func executionFailed(with info: [Info : Any?]?) -> AOperationError {
		return AOperationError(state: .executionFailed, info: info)
	}
	
    /// Returns an error with conditionFailed state and given info.
    /// - Parameter info: The error’s info dictionary.
	public static func conditionFailed(with info: [Info : Any?]?) -> AOperationError {
		return AOperationError(state: .conditionFailed, info: info)
	}
    
    
    /// Retrieve the localized description for this error.
    public var localizedDescription: String? {
        return self.info?[.localizedDescription] as? String
    }
    
    /// Retrieve the reason for the error.
    public var failureReason: String? {
        return self.info?[.reason] as? String
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

public extension Error {
        
    /**
     Maps error to given ErrorType
     
     Implement this method in to extension of Error types for your desired error types.
     By default this method returns `nil`.
     
     - Parameter type: The Error type you want to error be map to
     */
	func map<T: Error>(to type: T.Type) -> T? {
        return nil
    }
	
    /**
     Maps error to given ErrorType with a provided clousure
     
     Implement this method in to extension of Error types for your desired error types.
     By default this method returns `nil`.
     
     - Parameter mapHandler: The cloure used to map error to given ErrorType
     */
    func map<T: Error>(to mapHandler: (Self) -> T) -> T {
        return mapHandler(self)
    }
    
}

public extension AOperationError {
	
    /// The state to use for errors
	enum State: Int {
		case conditionFailed
		case executionFailed
	}

    /// The info key to use for errors info dictionary
	struct Info: RawRepresentable, Hashable {
		
		public var rawValue: String
		
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
        /// The key used for name of error's emitter
		public static let key = Info(rawValue: "key")
        
        /// The key used for code of error
        public static let errorCode = Info(rawValue: "errorCode")
        
        /// The key used for reason of error
		public static let reason = Info(rawValue: "reason")
        
        /// The key used for reason of error
		public static let localizedDescription = Info(rawValue: "localizedDescription")
        
        /// Use this key to check if Operation is canceled by user
		public static let isCancelled = Info(rawValue: "canceled")
        
	}
	
}
