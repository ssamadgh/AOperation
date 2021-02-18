/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This file shows how operations can be composed together to form new operations.
 */

import Foundation

/**
 A subclass of `VoidOperation` that executes zero or more operations as part of its
 own execution. This class of operation is very useful for abstracting several
 smaller operations into a larger operation.

 */
open class GroupOperation : VoidOperation {
	
    fileprivate let internalQueue = AOperationQueue()
	fileprivate let startingOperation = AOperationBlock(mainQueueBlock: {})
    fileprivate let finishingOperation = AOperationBlock(mainQueueBlock: {})

    fileprivate var aggregatedErrors = [AOperationError]()

    public convenience init(_ operations: Foundation.Operation...) {
        self.init(operations)
    }

	public init(_ operations: [Foundation.Operation]) {
        super.init()
		startingOperation.name = "startingOperation"
		finishingOperation.name = "finishingOperation"
        internalQueue.isSuspended = true
        internalQueue.delegate = self
        internalQueue.addOperation(startingOperation)

		self.addOperations(operations)
    }
	
	/// Adds the given operations to the queue of group operation
	///
	/// This method should be called before adding operation to the queue
	/// - Parameter operations: A list of operations to add to queue
	public func addOperations(_ operations: [Foundation.Operation]) {
		for operation in operations {
			self.addOperation(operation)
		}
	}

	override open func cancel() {
		internalQueue.operations.reversed().forEach({$0.cancel()})
        super.cancel()
    }

	override open func execute() {
        internalQueue.isSuspended = false
        internalQueue.addOperation(finishingOperation)
    }

	/// Adds the given operation to the queue of group operation
	///
	/// This method should be called before adding operation to the queue
	/// - Parameter operation: An operations to add to queue
    public func addOperation(_ operation: Foundation.Operation) {
        internalQueue.addOperation(operation)
    }
	
	public override func finish(with result: Result<Void, AOperationError>) {
		self.finishedResult = result
	}

    /**
     Note that some part of execution has produced an error.
     Errors aggregated through this method will be included in the final array
     of errors reported to observers and to the `finished(_:)` method.
     */
    public final func aggregateError(_ error: AOperationError) {
        aggregatedErrors.append(error)
    }

    open func operationDidFinish(_ operation: Foundation.Operation, withErrors errors: [AOperationError]) {
        // For use by subclasses.
    }
		
}

extension  GroupOperation: AOperationQueueDelegate {
	
	final public func operationQueue(_ operationQueue: AOperationQueue, willAddOperation operation: Foundation.Operation) {
		assert(!finishingOperation.isFinished && !finishingOperation.isExecuting, "cannot add new operations to a group after the group has completed")
		
		/*
		Some operation in this group has produced a new operation to execute.
		We want to allow that operation to execute before the group completes,
		so we'll make the finishing operation dependent on this newly-produced operation.
		*/
		if operation !== finishingOperation {
			finishingOperation.addDependency(operation)
		}
		
		/*
		All operations should be dependent on the "startingOperation".
		This way, we can guarantee that the conditions for other operations
		will not evaluate until just before the operation is about to run.
		Otherwise, the conditions could be evaluated at any time, even
		before the internal operation queue is unsuspended.
		*/
		if operation !== startingOperation {
			operation.addDependency(startingOperation)
		}
	}
	
	final public func operationQueue(_ operationQueue: AOperationQueue, operationDidFinish operation: Foundation.Operation, withErrors errors: [AOperationError]) {
		aggregatedErrors.append(contentsOf: errors)
		
		if operation === finishingOperation {
			internalQueue.isSuspended = true
			
			if let willFinish = self.willFinishCompletion  {
				let result: Result<Void, AOperationError> = aggregatedErrors.isEmpty ? .success(()) : .failure(aggregatedErrors.first!)
				willFinish(result) {
					finish(aggregatedErrors)
				}
			}
			else {
				finish(aggregatedErrors)
			}

		}
		else if operation !== startingOperation {
			operationDidFinish(operation, withErrors: errors)
		}
	}
	
	
}

