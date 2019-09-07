//
//  OrderedGroupOperation.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 5/14/19.
//

import Foundation

/**
 A subclass of `GroupOperation` that executes zero or more operations as part of its
 own execution in ordered way. This class of operation is very useful for abstracting several
 smaller operations into a larger operation.

Additionally, `OrderedGroupOperation`s are useful if you establish a chain of dependencies,
 but part of the chain may "loop". For example, if you have an operation that
 requires the user to be authenticated, you may consider putting the "login"
 operation inside a group operation. That way, the "login" operation may produce
 subsequent operations (still within the outer `GroupOperation`) that will all
 be executed before the rest of the operations in the initial chain of operations.
 
 - Note: The operations in  OrderedGroupOperation will be executed one by one,
            in order that they are passed to OrderedGroupOperation.
 */
open class OrderedGroupOperation: GroupOperation {
	
	
	override public init(operations: [Foundation.Operation]) {
		var lastIndex = operations.count - 1
		while lastIndex > 0 {
			let lastOp = operations[lastIndex]
			let previousLastOp = operations[lastIndex - 1]
			lastOp.addDependency(previousLastOp)
			lastIndex -= 1
		}
		
		super.init(operations: operations)
	}
	
	
	
}
