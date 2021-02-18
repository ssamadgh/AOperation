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
 
 - Note: The operations in  OrderedGroupOperation will be executed one by one,
            in order that they are passed to OrderedGroupOperation.
 */
open class OrderedGroupOperation: GroupOperation {
	
	
	override public init(_ operations: [Foundation.Operation]) {
		var lastIndex = operations.count - 1
		while lastIndex > 0 {
			let lastOp = operations[lastIndex]
			let beforeLastOp = operations[lastIndex - 1]
			lastOp.addDependency(beforeLastOp)
			lastIndex -= 1
		}
		
		super.init(operations)
	}
	
	
}
