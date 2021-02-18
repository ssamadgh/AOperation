//
//  Cloneable.swift
//  AOperation
//
//  Created by Seyed Samad Gholamzadeh on 12/5/20.
//

import Foundation

/// A protocol that operations conform to support attempts to recreate a finished operation.
///
/// This protocl should be conformed if you want to use `retryOnFailure` method or receive a sequence of values over time from a Combine upstream publishers.
public protocol RetryableOperation: class {
	
	/// Returns a new instance of the receiver.
	func new() -> Self
}


extension RetryableOperation where Self : AOperation {
	
	/// Returns a new instance that’s a clone of the receiver operation with its condition and qualityOfService.
	func clone() -> Self {
		let operation = self
		let new = operation.new()
		assert(!(new === operation), "The new() method should return a new instanse of \(type(of: self))")
		new.conditions(operation.conditions)
		new.observers(operation.observers)
		new.subscriberId = operation.subscriberId
		new.publisherId = operation.publisherId
		new.qualityOfService = operation.qualityOfService
		return new
	}
		
}
