/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

import Foundation

extension NoCanceledDependencies {
	
	public struct Error: LocalizedError{
		public let canceledDependencies: [String]
		
		public var errorDescription: String? {
			"failed because of cancelled dependencies \(canceledDependencies.joined(separator: ", "))"
		}
	}
    
}

/**
    A condition that specifies that every dependency must have succeeded.
    If any dependency was canceled, the target operation will be canceled as
    well.
*/
public struct NoCanceledDependencies: AOperationCondition {

    public static let isMutuallyExclusive = false
    
    public var dependentOperation: AOperation?
    
    public init() {
        // No op.
    }
    
    
    public func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
        // Verify that all of the dependencies executed.
		let canceled = operation.dependencies.filter { $0.isCancelled }

		if !canceled.isEmpty {
            // At least one dependency was canceled; the condition was not satisfied.
			let error = AOperationError(Error(canceledDependencies: canceled.compactMap({$0.name})))
            
            completion(.failure(error))
        }
        else {
            completion(.success)
        }
    }
}
