//
//  ReceiverOperation.swift
//  AOperation
//
//  Created by Seyed Samad Gholamzadeh on 12/10/20.
//

import Foundation

/// A Protocol that is parant of ReceiverOperation.
///
/// This protocol used to avoid Generic limitation of ReceiverOperation protocol
public protocol BaseReceiverOperation: AOperation {
	
	/// A generic method that accepts given operation to observe and receive its finished result.
	/// - Parameter operation: A ResultableOperation that observed to receive its finished result
	func accept<T, Operation: ResultableOperation<T>>(_ operation: Operation)
}


/// A protocol that declares an AOperation type that can receive input from a ResultableOperation or OperationPublisher.
public protocol ReceiverOperation: BaseReceiverOperation {
	
	associatedtype Input

	var receivedValue: Result<Input, AOperationError>? { get set}
	
}

public extension ReceiverOperation {
	// A default implementation for BaseReceiverOperation `func accept<T, Operation: ResultableOperation<T>>(_ operation: Operation)` method.
	//This implementation used as a workaround to avoid generic limitation
	func accept<T, Operation>(_ operation: Operation) where Operation : ResultableOperation<T> {
		if T.self == Input.self {
			operation.deliver(to: self)
		}
	}
}

public extension ResultableOperation {
	
	/// Tells the ResultableOperation that it had to deliver its result to the given subscriber operation.
	/// - Parameters:
	///   - operation: A ResultableOperation that conformed ReceiverOperation protocol
	@discardableResult
	func deliver<Operation: ReceiverOperation>(to operation: Operation) -> Operation {
		// We add current operation as dependency to the given operation to prevent it from executing before current operation finish.
		publisherId = UUID()
		operation.addDependency(self)
		operation.subscriberId = publisherId
		// we use willFinish observer to deliver result to the given operation
		// with willFinish observer method we move operation to finish state manually
		// by this we make sure the result delivered to the given operation
		self.willFinish { [weak operation] (result, finish) in
			switch result {
			case .success(let output):
				if let input = output as? Operation.Input {
					operation?.receivedValue = .success(input)
				}
				break
			case .failure(let error):
				operation?.receivedValue = .failure(error)
			}

			finish()
		}
		
		// Finally we add the given operation to the queue by the produce method.
		self.produce(operation)
		return operation
	}
	
}
