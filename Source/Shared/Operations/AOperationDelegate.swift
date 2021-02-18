//
//  AOperationDelegate.swift
//  AOperation
//
//  Created by Seyed Samad Gholamzadeh on 11/25/20.
//

import Foundation

/**
Methods for react to the changes of operation's lifecycle.


Use the methods of this protocol to react to the following states:

* Operation starts to executtion
* Operation finishes its execution
*/
public protocol AOperationDelegate: class {
	
	/// Tells the delegate the operation starts to execution
	/// - Parameter operation: The operation informing the delegate of this impending event.
	func operationDidStart(_ operation: AOperation)
	
	/// Tells the delegate the operation finishes its execution
	/// - Parameters:
	///   - operation: The operation informing the delegate of this impending event.
	///   - errors: The errors published by operation. The array would be empty if operation finishes successfully.
	func operationDidFinish(_ operation: AOperation, with errors: [AOperationError])
}

public extension AOperationDelegate {
	
	func operationDidStart(_ operation: AOperation) {}
	
	func operationDidFinish(_ operation: AOperation, with errors: [AOperationError]) {}
}
