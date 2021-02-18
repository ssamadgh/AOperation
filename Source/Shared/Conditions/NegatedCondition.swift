/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The file shows how to make an OperationCondition that composes another OperationCondition.
*/

import Foundation

extension NegatedCondition {

	public struct Error: LocalizedError {
		public let negatedConditionKey: String
		
		public var errorDescription: String? {
			return "The condition \(negatedConditionKey) succeed"
		}
		
		init(_ negatedConditionKey: String) {
			self.negatedConditionKey = negatedConditionKey
		}
	}
	
}

/**
    A simple condition that negates the evaluation of another condition.
    This is useful (for example) if you want to only execute an operation if the
    network is NOT reachable.
*/
public struct NegatedCondition<T: AOperationCondition>: AOperationCondition {
    
    public var dependentOperation: AOperation?
    
    static var negatedConditionKey: String {
        return "\(T.key)"
    }
    
   public static var isMutuallyExclusive: Bool {
        return T.isMutuallyExclusive
    }
    
    let condition: T

    public init(_ condition: T) {
        self.condition = condition
    }
    
    public func dependencyForOperation(_ operation: AOperation) -> AOperation? {
        let operation = condition.dependencyForOperation(operation)
        return operation
    }
    
    public func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
        condition.evaluateForOperation(operation) { result in
			if case .success = result {
                // If the composed condition succeeded, then this one failed.
              
				let error = AOperationError(Error(NegatedCondition<T>.negatedConditionKey))
                
                completion(.failure(error))
            }
            else {
                // If the composed condition failed, then this one succeeded.
                completion(.success)
            }
        }
    }
}
