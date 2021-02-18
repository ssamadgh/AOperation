//
//  VoidOperation.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 12/11/20.
//

import Foundation

extension Result {
	public var error: Failure? {
		if case .failure(let error) = self {
			return error
		}
		
		return nil
	}
}

/// A subclass of ResultableOperation without Void type
///
/// Use this class if you do not need to publish an element as result of operation exectution
open class VoidOperation: ResultableOperation<Void> {
		
	override func finished(_ errors: [AOperationError]) {
		if errors.isEmpty {
			finishedResult = .success(())
		}
		super.finished(errors)
	}
}


public extension ResultableOperation where Output == Void {
	
	/// Finishes operation with the given error
	/// - Parameter error: An error that operation published or nil if operation finished successfully
	final func finish(_ error: AOperationError? = nil) {
		let result: Result<Void, AOperationError>
		
		if let error = error {
			result = .failure(error)
		}
		else {
			result = .success(())
		}
		
		self.finish(with: result)
	}
	

	
}
