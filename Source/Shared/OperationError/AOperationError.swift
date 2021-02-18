/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This file defines the errors and convenience functions for interacting with AOperation-related errors.
 */

import Foundation


/// Error published by AOperation objects.
public struct AOperationError: LocalizedError, Equatable, CustomDebugStringConvertible {
	
	
	public var debugDescription: String {
		"AOperationError state: \(state), publisher: \(publisher ?? ""), publishedError: \(publishedError)"
	}
			
	
    /**
     The state that error published
     
     If state be condition, means error is belong to a condition, if state be execution means error belongs to an operation.
     */
	public internal(set) var state: FailureState = .execution
    	
	
	/// The error published with publisher
	public let publishedError: Error
	    
	/// Name of the error publisher.
	///
	/// This proprty for Operations is the name of the operation and is equal to the type of operation
	/// unless user set a custom name on it
	/// For conditions is the key of condition and is equal to the type of condition
	/// unless user set a custom key on it
	public internal(set) var publisher: String?
	
    /// Initializes an error with a given state and info dictionary.
    /// - Parameter state: The state of error emitation
    /// - Parameter info: The error’s info dictionary.
	public init(_ failureError: Error) {
		self.publishedError = failureError
	}
	
	public var errorDescription: String {
		return publishedError.localizedDescription
	}
	
	public var localizedDescription: String {
		return publishedError.localizedDescription
	}
    
    public var failureReason: String? {
		return (publishedError as? LocalizedError)?.failureReason
    }
	
	public var recoverySuggestion: String? {
		return (publishedError as? LocalizedError)?.recoverySuggestion
	}
	
	public var helpAnchor: String? {
		return (publishedError as? LocalizedError)?.helpAnchor
	}
        
}


public func == (lhs: AOperationError, rhs: AOperationError) -> Bool {
	let result: Bool
	
	let leftErrorDescription = lhs.publishedError.localizedDescription
	let rightErrorDescription = rhs.publishedError.localizedDescription

	result = (
		lhs.state == rhs.state
		&& lhs.publisher == rhs.publisher
		&& leftErrorDescription == rightErrorDescription
	)
	
	return result
}

public extension AOperationError {
	
    /// The state to use for errors
	enum FailureState: Int {
		case condition
		case execution
	}
}


public extension AOperationError {
	
	/// An error that indicates the operation is cancelled
	struct IsCancelled: LocalizedError {
		
		let operationName: String?
		
		init(_ operation: AOperation) {
			self.operationName = operation.name
		}
		public var errorDescription: String? {
			return "The Operation \(operationName ?? "") is Cancelled"
		}
	}
	
	struct ReceivedValueIsNil: LocalizedError {
		let operationName: String?
		
		public init(_ operation: AOperation) {
			self.operationName = operation.name
		}
		public var errorDescription: String? {
			return "The received value to operation \(operationName ?? "") is nil"
		}
	}
	
	static func receivedValueIsNil(in operation: AOperation) -> AOperationError {
		AOperationError(ReceivedValueIsNil(operation))
	}
	
	static func isCancelled(_ operation: AOperation) -> AOperationError {
		AOperationError(IsCancelled(operation))
	}
}
