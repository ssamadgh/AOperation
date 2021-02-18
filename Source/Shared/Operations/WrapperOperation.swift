//
//  WrapperOperation.swift
//  AOperation
//
//  Created by Seyed Samad Gholamzadeh on 12/22/20.
//

import Foundation

/// A subclass of ResultableOperation that conformed SubscriberOperation protocol and wraps a given operation and publishes its result
///
/// Use this class to wrap several SubscriberOperation in one operation and publish their final result.
/// Also you can manage the received value as your desired and then deliver it to wrapped operation
/// This Class gets three Type as Generic types:
///An Input type for the received value type
/// An Output for the published result value type
/// A ResultableOperation that is the type of wrapped operation
open class WrapperOperation<Input, Output>: ResultableOperation<Output>, ReceiverOperation {
		
	fileprivate let internalQueue = AOperationQueue()

	public var receivedValue: Result<Input, AOperationError>?
		
	let generator: (Result<Input, AOperationError>?) -> ResultableOperation<Output>?
	
	/// Initiailizes a WrapperOperation with the given closure
	/// - Parameter generator: A closure that generates wrapped operation wich has an input and a return
	///- receivedValue: the received value by the wrapper operation
	/// - Returns: An instance of operation that should be wrapped
	public init(generator: @escaping (_ receivedValue: Result<Input, AOperationError>?) -> ResultableOperation<Output>?) {
		self.generator = generator
		super.init()
		internalQueue.isSuspended = true
	}
	
	override open func cancel() {
		internalQueue.cancelAllOperations()
		super.cancel()
	}

	open override func execute() {
		guard let operation = generator(receivedValue) else {
			self.finish([])
			return
		}
		operation.didFinish({ [weak self] (result) in
			self?.finish(with: result)
		})
		.add(to: internalQueue)
		internalQueue.isSuspended = false
	}
	
	
}
