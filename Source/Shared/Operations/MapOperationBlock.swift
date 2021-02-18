//
//  MapOperationBlock.swift
//  AOperation
//
//  Created by Seyed Samad Gholamzadeh on 2/13/21.
//

/*
Abstract:
This code shows how to create a simple subclass of AOperation.
*/

import Foundation

/// A sublcass of `ResultableOperation` that execute a closure that receives value from upstream operation and results an output with the given type.
///
/// Use this operation if you want to change the type of upstream operation result to a new type.
public class MapOperationBlock<Input, Output>: ResultableOperation<Output>, ReceiverOperation {
	
	/// A closure type that takes a closure as its parameter.
	public typealias MapBlock = ((Result<Input, AOperationError>?), @escaping (Result<Output, AOperationError>) -> Void) -> Void

	public var receivedValue: Result<Input, AOperationError>?
	
   fileprivate let block: MapBlock

   /**
	The designated initializer.

	- parameter block: The closure to run when the operation executes. This
	closure will be run on an arbitrary queue. The parameter passed to the
	block **MUST** be invoked by your code, or else the `BlockOperation`
	will never finish executing.
	*/
	public init(block: @escaping MapBlock) {
	   self.block = block
	   super.init()
   }

   override public func execute() {
	   guard !isCancelled else {
		finish(with: .failure(AOperationError.isCancelled(self)))
		   return
	   }

	   block(receivedValue) { result in
		self.finish(with: result)
	   }
   }
	
}

