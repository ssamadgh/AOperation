/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This file contains an Foundation.OperationQueue subclass.
 */

import Foundation

/**
 The delegate of an `AOperationQueue` can respond to `AOperation` lifecycle
 events by implementing these methods.

 In general, implementing `AOperationQueueDelegate` is not necessary; you would
 want to use an `AOperationObserver` instead. However, there are a couple of
 situations where using `AOperationQueueDelegate` can lead to simpler code.
 For example, `GroupOperation` is the delegate of its own internal
 `AOperationQueue` and uses it to manage dependencies.
 */
public protocol AOperationQueueDelegate: class {
    func operationQueue(_ operationQueue: AOperationQueue, willAddOperation operation: Foundation.Operation)
    func operationQueue(_ operationQueue: AOperationQueue, operationDidFinish operation: Foundation.Operation, withErrors errors: [AOperationError])
}

public extension AOperationQueueDelegate {
	func operationQueue(_ operationQueue: AOperationQueue, willAddOperation operation: Foundation.Operation) {}
	func operationQueue(_ operationQueue: AOperationQueue, operationDidFinish operation: Foundation.Operation, withErrors errors: [AOperationError]) {}
}

/**
	A queue that regulates the execution of AOperations.

 `AOperationQueue` is an `Foundation.OperationQueue` subclass that implements a large
 number of "extra features" related to the `AOperation` class:

 - Notifying a delegate of all operation completion
 - Extracting generated dependencies from operation conditions
 - Setting up dependencies to enforce mutual exclusivity
 */
public class AOperationQueue: Foundation.OperationQueue {
	
	public static let shared = AOperationQueue()

	
    public weak var delegate: AOperationQueueDelegate?

	override public func addOperation(_ op: Foundation.Operation) {
        if let op = op as? AOperation {
			guard op.isInitialized else { return }
			if op is UniqueOperation {
				if UniquenessController.shared.contains(op as! (AOperation & UniqueOperation)) {
					if AOperation.Debugger.printOperationsState {
						print("AOperation \(op.name ?? "\(type(of: op))") ignored because of uniqueId \((op as! (AOperation & UniqueOperation)).uniqueId)")
					}
					return
				}
			}
			
		
            // Set up a `BlockObserver` to invoke the `AOperationQueueDelegate` method.
            let delegate = BlockObserver(
                startHandler: nil,
                produceHandler: { [weak self] in
                    self?.addOperation($1)
                },
                finishHandler: { [weak self] in
                    if let q = self {
                        q.delegate?.operationQueue(q, operationDidFinish: $0, withErrors: $1)
                    }
                }
            )
            op.addObserver(delegate)

            // Extract any dependencies needed by this operation.
			let dependencies = op.conditions.compactMap {
                $0.dependencyForOperation(op)
            }

            for dependency in dependencies {
                op.addDependency(dependency)

                self.addOperation(dependency)
            }

            /*
             With condition dependencies added, we can now see if this needs
             dependencies to enforce mutual exclusivity.
             */
			let concurrencyCategories: [String] = op.conditions.compactMap { condition in
                if !type(of: condition).isMutuallyExclusive { return nil }

                return "\(type(of: condition))"
            }

            if !concurrencyCategories.isEmpty {
                // Set up the mutual exclusivity dependencies.
                let exclusivityController = ExclusivityController.shared

                exclusivityController.addOperation(op, categories: concurrencyCategories)

				op.addObserver(BlockObserver(finishHandler:  { operation, _ in
					exclusivityController.removeOperation(operation, categories: concurrencyCategories)
				}))
				

            }
			
			if op is UniqueOperation {
				UniquenessController.shared.addOperation(op as! (AOperation & UniqueOperation))
				op.addObserver(BlockObserver(startHandler: nil, produceHandler: nil, finishHandler: { (operation, _) in
					UniquenessController.shared.removeOperation(operation as! (AOperation & UniqueOperation))
				}))
			}

            /*
             Indicate to the operation that we've finished our extra work on it
             and it's now it a state where it can proceed with evaluating conditions,
             if appropriate.
             */
            op.didEnqueue()
        }
        else {
            /*
             For regular `NSOperation`s, we'll manually call out to the queue's
             delegate we don't want to just capture "operation" because that
             would lead to the operation strongly referencing itself and that's
             the pure definition of a memory leak.
             */
            op.addCompletionBlock { [weak self, weak op] in
                guard let queue = self, let operation = op else { return }
                queue.delegate?.operationQueue(queue, operationDidFinish: operation, withErrors: [])
            }
        }

        delegate?.operationQueue(self, willAddOperation: op)

		if AOperation.Debugger.printOperationsState {
			print("AOperation \(op.name ?? "\(type(of: op))") added to queue")
		}

        super.addOperation(op)
    }

	override public func addOperations(_ ops: [Foundation.Operation], waitUntilFinished wait: Bool) {
        /*
         The base implementation of this method does not call `addOperation()`,
         so we'll call it ourselves.
         */
        for operation in ops {
            addOperation(operation)
        }

        if wait {
            for operation in ops {
                operation.waitUntilFinished()
            }
        }
    }
}

