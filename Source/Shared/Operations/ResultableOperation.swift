//
//  ResultAOperation.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 12/5/19.
//

import Foundation

/// A subclass of AOperation that publishes a result value when finishes its execution.
///
/// The result value represents either a success or a failure, including an associated value in each case.
open class ResultableOperation<Output>: AOperation {
	let serialQueue: DispatchQueue = {
		let queue = OS_dispatch_queue_serial(label: "com.resultableOperation.serialQueue")
		return queue
	}()
	
	private var numberOfRetries: NumberOfRetries = 0
	
    internal var finishedResult: Result<Output, AOperationError>?
    private var didFinishCompletions: [((Result<Output, AOperationError>) -> Void)] = []
	 var willFinishCompletion:((Result<Output, AOperationError>, _ finish: () -> Void) -> Void)?
	
	/// A method that observes operation when it moves to the finished state.
	/// You can call this method several time and all of your methods closure will be execute when operation finished.
	/// The closure of this method executes in main thread.
	/// - Parameter completion: A closure that get called when operation moves to finished state
	@discardableResult
    public final func didFinish(_ completion: @escaping (Result<Output, AOperationError>) -> Void) -> Self {
		assert(isInitialized, "Adding didFinishCompletion closure after adding operaiotn to queue is not allowed")
		serialQueue.async {
			self.didFinishCompletions.append(completion)
		}
		return self
    }
	
	/// A method that observes operation when it moves to the finishing state.
	///
	/// By using this method you should handle moving operation to finished state manually by calling finish() method in closure
	///- Note:
	///* This method just accepts the last closure you set to observe willFinish.
	/// Meaning that if you call this method twice. the closure of last call of method will accept.
	///* If you call deliver(to:) method for an operation all willFinish(_:) methods calling before it will be ignored.

	/// - Parameter completion: A closuer that get called when operation moves to finishing state. You should call fnish() method manaully in closure to operation move to finished state.
	@discardableResult
	public final func willFinish(_ completion: @escaping (Result<Output, AOperationError>, _ finish: () -> Void) -> Void) -> Self {
		assert(isInitialized, "Adding willFinishCompletion closure after adding operation to queue is not allowed")
		self.willFinishCompletion = completion
		return self
	}
        
    private func privateFinish(with result: Result<Output, AOperationError>) {
		let completions = self.didFinishCompletions
		DispatchQueue.main.async {
			completions.forEach({$0(result)})
		}
		didFinishCompletions.removeAll()
    }
	
	/// Finishes operation with the given result
	///
	/// call this method in execute method of operation
	/// - Parameter result: A result value that operation should publish
	public func finish(with result: Result<Output, AOperationError>) {
		var result = result
		if var error = result.error {
			error.state = .execution
			error.publisher = error.publisher ?? self.name
			result = .failure(error)
		}
		self.finishedResult = result
		
		var opErrors: [AOperationError] = []
		switch result {
		case let .failure(error):
			opErrors.append(error)
		default:
			break
		}
		
		if let willFinish = self.willFinishCompletion {
			willFinish(result) { [weak self] in
				self?.finish(opErrors)
				self?.willFinishCompletion = nil
			}
		}
		else {
			self.finish(opErrors)
		}
	}
    	
    override func finished(_ errors: [AOperationError]) {
        if let error = errors.first {
            let result: Result<Output, AOperationError> = .failure(error)
			guard retryHandler != nil else {
				self.privateFinish(with: result)
				return
			}
			
			retryHandler!(numberOfRetries, error) { askedForRetry in
				if askedForRetry {
					self.numberOfRetries += 1
					self.retry()
				}
				else {
					self.privateFinish(with: result)
				}
				
			}
			
			
        }
        else {
            
            if let result = self.finishedResult {
                self.privateFinish(with: result)
            }
        }
    }
	
	deinit {
		retryHandler = nil
		willFinishCompletion = nil
		didFinishCompletions.removeAll()
	}
	
	private var retryHandler: ((_ numberOfRetries: NumberOfRetries, _ error: AOperationError, _ retry: @escaping Retry) -> Void)?
	
	/// Attempts to recreate a failed operation and its upstream dependencies up to the number of times you specify.
	/// This method checks if the publisher of error is one of its upstream dependencies
	/// starts the retry flow from there. For example if we have a chain of operaions like below
	///```
	///OperationA()
	///.deliver(to: OpeationB())
	///.deliver(to: OperationC())
	///.retryOnFailure { numberOfRetries, retry in
	///	 retry(true)
	///}
	///.didFinish { result in
	///
	///}
	///```
	///And the failure operation would be OperationB, the retry method recreats flow from there,
	///If failure operation would be OperationA, the retry method starts from there.
	///
	///- Note: This method just accepts the last closure you set to observe willFinish.
	/// Meaning that if you call this method twice. the closure of last call of method will accept.
	/// - Parameters:
	/// 	- retryHandler: A closure that get called when operation failed.
	/// This closure has three parameters:
	///		- numberOfRetries: Gives the number of timse operation retried. For the first time its value is 0.
	///		- error: The failed error of operation.
	///		- retry: A retry method that gets a boolian value as input. If you set true it retries the flow of operation and its dependencies, If you set false it finishes operation and publishes the failed error as result.
	@discardableResult
	public func retryOnFailure(_ retryHandler: @escaping (_ numberOfRetries: NumberOfRetries, _ error: AOperationError, _ retry: @escaping Retry) -> Void) -> Self {
		assert(isInitialized, "Adding retryOnFailureHandler closure after adding operaiotn to queue is not allowed")
		self.retryHandler = retryHandler
		return self
	}
	
	override func retry() {
		// Here we use clone method to create a new instance of operation and updating its numberOfRetries, didFinish, willFinish and retry closures. in addition we check if the publisher of error is one of its upstream dependencies we start the retry flow from there
		guard let operation = self as? (ResultableOperation<Output> &
		RetryableOperation)
		else { fatalError("The operation doesn't conform `RetryableOperation protocol") }
		let cloned = operation.clone()
		cloned.numberOfRetries = numberOfRetries
		cloned.didFinishCompletions = didFinishCompletions
		cloned.willFinishCompletion = willFinishCompletion
		cloned.retryHandler = operation.retryHandler

		if let failedDependency = operation.dependencies.first(where: {($0 as? AOperation)?.publisherId == operation.subscriberId}) as? (AOperation & RetryableOperation), !failedDependency.publishedErrors.isEmpty {
			failedDependency.retryAsFailedDependency(of: cloned)
		}
		else {
			produce(cloned)
		}
	}
	
	override func retryAsFailedDependency(of operation: AOperation) {
		// Here we handle retry flow for updatream dependencies
		guard let dependency = self as? (ResultableOperation<Output> &
		RetryableOperation)
		else { fatalError("The operation doesn't conform `RetryableOperation protocol") }
		let cloned = dependency.clone()
		cloned.numberOfRetries = dependency.numberOfRetries
		cloned.didFinishCompletions = dependency.didFinishCompletions
		cloned.willFinishCompletion = dependency.willFinishCompletion
		cloned.retryHandler = dependency.retryHandler
		
		// Its imprtant if the operation is subscribed to the upstream dependency we accept its subscription again by using accept(_:) method of upstream operation as a BaseSubscriberOperation
		(operation as? BaseReceiverOperation)?.accept(cloned)
		
		if let failedDependency = dependency.dependencies.first(where: {($0 as? AOperation)?.publisherId == dependency.subscriberId}) as? (AOperation & RetryableOperation), !failedDependency.publishedErrors.isEmpty {
			failedDependency.retryAsFailedDependency(of: cloned)
		}
		else {
			produce(cloned)
		}
	}
    
	//
	open override func cancel() {
		super.cancel()
		
		if self is BaseReceiverOperation {
			dependencies.first(where: {($0 as? AOperation)?.publisherId == subscriberId})?.cancel()
		}
	}
}

public typealias NumberOfRetries = Int
public typealias Retry =   (Bool) -> Void
