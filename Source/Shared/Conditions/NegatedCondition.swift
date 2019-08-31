/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The file shows how to make an OperationCondition that composes another OperationCondition.
*/

import Foundation

extension NegatedCondition {
	struct ErrorInfo {
		static var inputCondition: AOperationError.Info {
			return AOperationError.Info(rawValue: "NegatedCondition")
		}
	}
}

/**
    A simple condition that negates the evaluation of another condition.
    This is useful (for example) if you want to only execute an operation if the
    network is NOT reachable.
*/
public struct NegatedCondition<T: AOperationCondition>: AOperationCondition {
    
    public static var name: String {
        return "NegatedCondition"
    }
    
    static var negatedConditionKey: String {
        return "\(T.name)"
    }
    
   public static var isMutuallyExclusive: Bool {
        return T.isMutuallyExclusive
    }
    
    let condition: T

    public init(condition: T) {
        self.condition = condition
    }
    
    public func dependencyForOperation(_ operation: AOperation) -> Foundation.Operation? {
        return condition.dependencyForOperation(operation)
    }
    
    public func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
        condition.evaluateForOperation(operation) { result in
            if result == .satisfied {
                // If the composed condition succeeded, then this one failed.
				let errorInfo: [AOperationError.Info : Any?] =
				[
					.key : type(of: self).name,
					NegatedCondition.ErrorInfo.inputCondition : type(of: self.condition).name
				]
              
				let error = AOperationError.conditionFailed(with: errorInfo)
                
                completion(.failed(error))
            }
            else {
                // If the composed condition failed, then this one succeeded.
                completion(.satisfied)
            }
        }
    }
}
