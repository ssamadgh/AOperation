/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The file shows how to make an OperationCondition that composes another OperationCondition.
*/

import Foundation

/**
    A simple condition that causes another condition to not enqueue its dependency.
    This is useful (for example) when you want to verify that you have access to
    the user's location, but you do not want to prompt them for permission if you
    do not already have it.
*/
public struct SilentCondition<T: AOperationCondition>: AOperationCondition {
    
    let condition: T
    
    public var dependentOperation: AOperation?
        
	public static var isMutuallyExclusive: Bool {
        return T.isMutuallyExclusive
    }
    
    public init(_ condition: T) {
        self.condition = condition
    }
    
	public func dependencyForOperation(_ operation: AOperation) -> Foundation.Operation? {
        // Returning nil means we will never a dependency to be generated.
        return nil
    }
    
	public func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
        condition.evaluateForOperation(operation, completion: completion)
    }
}
