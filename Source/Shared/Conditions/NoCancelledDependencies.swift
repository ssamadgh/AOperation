/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

import Foundation

/**
    A condition that specifies that every dependency must have succeeded.
    If any dependency was canceled, the target operation will be canceled as
    well.
*/
struct NoCanceledDependencies: OperationCondition {

    static let name = "NoCanceledDependencies"
    static let canceledDependenciesKey = "CanceledDependencies"
    static let isMutuallyExclusive = false
    
    init() {
        // No op.
    }
    
    func dependencyForOperation(_ operation: AOperation) -> Foundation.Operation? {
        return nil
    }
    
    func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
        // Verify that all of the dependencies executed.
		let canceled = operation.dependencies.filter { $0.isCancelled }

		if !canceled.isEmpty {
            // At least one dependency was canceled; the condition was not satisfied.
            let error = NSError(code: .conditionFailed, userInfo: [
                OperationConditionKey: type(of: self).name,
                type(of: self).canceledDependenciesKey: canceled
            ])
            
            completion(.failed(error))
        }
        else {
            completion(.satisfied)
        }
    }
}
