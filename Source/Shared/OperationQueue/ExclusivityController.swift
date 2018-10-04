/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This file contains the code to automatically set up dependencies between mutually exclusive operations.
 */

import Foundation

/**
 `ExclusivityController` is a singleton to keep track of all the in-flight
 `AOperation` instances that have declared themselves as requiring mutual exclusivity.
 We use a singleton because mutual exclusivity must be enforced across the entire
 app, regardless of the `AOperationQueue` on which an `AOperation` was executed.
 */
class ExclusivityController {
    internal static let shared = ExclusivityController()

    fileprivate let serialQueue = DispatchQueue(label: "Operations.ExclusivityController", attributes: [])
    fileprivate var operations: [String: [AOperation]] = [:]

    fileprivate init() {
        /*
         A private initializer effectively prevents any other part of the app
         from accidentally creating an instance.
         */
    }

    /// Registers an operation as being mutually exclusive
    internal func addOperation(_ operation: AOperation, categories: [String]) {
        /*
         This needs to be a synchronous operation.
         If this were async, then we might not get around to adding dependencies
         until after the operation had already begun, which would be incorrect.
         */
        serialQueue.sync {
            for category in categories {
                self.noqueue_addOperation(operation, category: category)
            }
        }
    }

    /// Unregisters an operation from being mutually exclusive.
    internal func removeOperation(_ operation: AOperation, categories: [String]) {
        serialQueue.async {
            for category in categories {
                self.noqueue_removeOperation(operation, category: category)
            }
        }
    }


    // MARK: AOperation Management

    fileprivate func noqueue_addOperation(_ operation: AOperation, category: String) {
        var operationsWithThisCategory = operations[category] ?? []

        if let last = operationsWithThisCategory.last {
            operation.addDependency(last)
        }

        operationsWithThisCategory.append(operation)

        operations[category] = operationsWithThisCategory
    }

    fileprivate func noqueue_removeOperation(_ operation: AOperation, category: String) {
        let matchingOperations = operations[category]

        if var operationsWithThisCategory = matchingOperations,
            let index = operationsWithThisCategory.index(of: operation) {

            operationsWithThisCategory.remove(at: index)
            operations[category] = operationsWithThisCategory
        }
    }

}

