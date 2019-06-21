//
//  OrderedGroupOperation.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 5/14/19.
//

import Foundation


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
