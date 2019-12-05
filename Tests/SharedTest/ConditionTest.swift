//
//  ConditionTest.swift
//  AOperation_iOS_Tests
//
//  Created by Seyed Samad Gholamzadeh on 12/5/19.
//

import XCTest
@testable import AOperation


/// This class testing condition in several situation to confirm that its work correctly as expects.

class ConditionTest: XCTestCase {

	let operationQueue = AOperationQueue()
	
	func testFailedConditionWithDependOperationError() {
		
		let expect = expectation(description: "FailedCondition expectation")
		
		let operation = TestOperation()
		operation.addCondition(FailedCondition())
		
		operation.observeDidFinish { (errors) in
			
			guard
				let error = errors.first,
				error.state == .conditionFailed,
				error.key == FailedCondition.key,
				error.failureReason == FailedConditionOperation.uniqueId.uuidString
			else {
				
				assert(false, "operation doesn't cancel for operation")
				return
			}
			
			
			expect.fulfill()
			
		}
		self.operationQueue.addOperation(operation)
		
		wait(for: [expect], timeout: 10)
		
	}
	
	func testSucceedCondition() {
		
		let expect = expectation(description: "SucceedCondition expectation")
		
		let operation = TestOperation()
		operation.addCondition(SucceedCondition())
		
		operation.observeDidFinish { (errors) in
			
			if let error = errors.first,
				error.state == .conditionFailed {
				
				assert(false, "operation doesn't cancel for operation")
				return
			}
			
			expect.fulfill()
			
		}
		self.operationQueue.addOperation(operation)
		
		wait(for: [expect], timeout: 10)
		
	}
	
	func testFailedConditionWithItsDefinedError() {
		
		let expect = expectation(description: "FailedCondition expectation")
		
		let operation = TestOperation()
		operation.addCondition(FailedConditionWithItsDefinedError())
		
		operation.observeDidFinish { (errors) in
			
			guard
				let error = errors.first,
				error.state == .conditionFailed,
				error.key == FailedConditionWithItsDefinedError.key,
				error.failureReason == FailedConditionWithItsDefinedError.uniqueId.uuidString
			else {
				
				assert(false, "operation doesn't cancel for Its defined Error")
				return
			}
			
			
			expect.fulfill()
			
		}

		self.operationQueue.addOperation(operation)
		
		wait(for: [expect], timeout: 10)

	}
	

}




class TestOperation: AOperation {
	
	override func execute() {
		self.finishWithError(nil)
	}
	
}

struct FailedConditionWithItsDefinedError: AOperationCondition {
	
	static let uniqueId = UUID()
	
	var dependentOperation: AOperation? = FailedConditionOperation()
	
	static var isMutuallyExclusive: Bool = true
	
	func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
		let error = AOperationError.conditionFailed(with: [.key : Self.key, .reason : FailedConditionWithItsDefinedError.uniqueId.uuidString])
		completion(.failed(error))
	}
	
}


struct FailedCondition: AOperationCondition {
	
	var dependentOperation: AOperation? = FailedConditionOperation()
	
	static var isMutuallyExclusive: Bool = true
	
	
}


class FailedConditionOperation: AOperation {
	
	static let uniqueId = UUID()

	override func execute() {
		let error = AOperationError.executionFailed(with: [.key : Self.key, .localizedDescription: "FailedConditionTestOperation is Failed", .reason : FailedConditionOperation.uniqueId.uuidString])
		
		self.finishWithError(error)
	}
	
}

struct SucceedCondition: AOperationCondition {
	
	var dependentOperation: AOperation? = SucceedConditionOperation()
	
	static var isMutuallyExclusive: Bool = true
		
}



class SucceedConditionOperation: AOperation {
	
	override func execute() {
		self.finishWithError(nil)
	}
	
}
