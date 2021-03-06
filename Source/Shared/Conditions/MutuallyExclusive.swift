/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This file shows an example of implementing the OperationCondition protocol.
 */

import Foundation

/// A generic condition for describing kinds of operations that may not execute concurrently.
public struct MutuallyExclusive<T>: AOperationCondition {
    
    
    public var dependentOperation: AOperation? = nil

    public static var key: String {
        return "MutuallyExclusive<\(T.self)>"
    }

	public static var isMutuallyExclusive: Bool {
        return true
    }

    public init() { }


	public func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
        completion(.success)
    }
}

/**
 The purpose of this enum is to simply provide a non-constructible
 type to be used with `MutuallyExclusive<T>`.
 */
public enum Alert { }

/// A condition describing that the targeted operation may present an alert.
public typealias AlertPresentation = MutuallyExclusive<Alert>

