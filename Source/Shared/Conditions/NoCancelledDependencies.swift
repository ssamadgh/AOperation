/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

import Foundation

extension NoCanceledDependencies {
	struct ErrorInfo {
		static let canceledDependencies = AOperationError.Info(rawValue: "CanceledDependencies")

	}
    
    
}

/**
    A condition that specifies that every dependency must have succeeded.
    If any dependency was canceled, the target operation will be canceled as
    well.
*/
public struct NoCanceledDependencies: AOperationCondition {

    public static let key = "NoCanceledDependencies"
    static let canceledDependenciesKey = "CanceledDependencies"
    public static let isMutuallyExclusive = false
    
    public init() {
        // No op.
    }
    
    public func dependencyForOperation(_ operation: AOperation) -> Foundation.Operation? {
        return nil
    }
    
    public func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
        // Verify that all of the dependencies executed.
		let canceled = operation.dependencies.filter { $0.isCancelled }

		if !canceled.isEmpty {
            // At least one dependency was canceled; the condition was not satisfied.
			let error = AOperationError.conditionFailed(with: [.key : Self.key, Self.ErrorInfo.canceledDependencies : canceled])
            
            completion(.failed(error))
        }
        else {
            completion(.satisfied)
        }
    }
}
