//
//  ConditionTest.swift
//  AOperation_iOS_Tests
//
//  Created by Seyed Samad Gholamzadeh on 12/5/19.
//

#if os(iOS) || os(macOS) || os(tvOS)

import XCTest
@testable import AOperation


/// This class testing condition in several situation to conform that its work correctly as expects.

class ConditionTest: XCTestCase {

	let queue = AOperationQueue()
	
	func testSucceedCondition() {

		let expect = expectation(description: "SucceedCondition expectation")

		let operation = OperationA()
		operation.conditions(SucceedCondition())

		operation.didFinish { (result) in

			if let error = result.error,
				error.state == .condition {
				assertionFailure("operation canceled with condition error")
				return
			}

			expect.fulfill()

		}
		.add(to: queue)

		wait(for: [expect], timeout: 10)
	}
	
	func testFailedCondition() {
		
		let expect = expectation(description: "FailedCondition expectation")
		
		let operation = OperationA()
		operation.conditions(FailedCondition())
		
		operation.didFinish { (result) in
			
			guard
				let error = result.error
			else {
				
				XCTAssert(false, "operation doesn't cancel for condition")
				return
			}

			guard
				error.state == .condition
			else {
				XCTAssert(false, "operation error state isn't condition")
				return
			}

			guard
				error.publisher == FailedCondition.key
			else {
				
				XCTAssert(false, "operation publisher isn't \(FailedCondition.key)")
				return
			}

			print("🚫\(error.localizedDescription)🚫")
			print("🚫\(FailedConditionError().localizedDescription)🚫")
			guard
				error.publishedError is FailedConditionError, error.localizedDescription == FailedConditionError().localizedDescription
			else {
				
				XCTAssert(false, "operation published error isn't \(String(describing: FailedConditionError.self))")
				return
			}
			
			
			expect.fulfill()
			
		}
		.add(to: queue)
		
		wait(for: [expect], timeout: 10)
		
	}
	
	func testSucceedConditionWithDependedOperation() {
		let expect = expectation(description: "SucceedCondition expectation")

		let operation = OperationA()
		operation.conditions(SucceedOperationCondition())

		operation.didFinish { (result) in

			if let error = result.error,
				error.state == .condition {
				assertionFailure("operation canceled with condition error")
				return
			}

			expect.fulfill()

		}
		.add(to: queue)

		wait(for: [expect], timeout: 10)

	}
	
	func testFailedConditionWithDependedOperation() {

		let expect = expectation(description: "FailedCondition expectation")
		
		let operation = OperationA()
		operation.conditions(FailedOperationCondition())
		
		operation.didFinish { (result) in
			
			guard
				let error = result.error
			else {
				
				XCTAssert(false, "operation doesn't cancel for condition")
				return
			}

			guard
				error.state == .condition
			else {
				XCTAssert(false, "operation error state isn't condition")
				return
			}

			guard
				error.publisher == FailedOperationCondition.key
			else {
				
				XCTAssert(false, "operation publisher isn't \(FailedOperationCondition.key)")
				return
			}

			print("🚫\(error.localizedDescription)🚫")
			print("🚫\(FailedOperationError().localizedDescription)🚫")
			guard
				error.publishedError is FailedOperationError, error.localizedDescription == FailedOperationError().localizedDescription
			else {
				
				XCTAssert(false, "operation published error isn't \(String(describing: FailedOperationError.self))")
				return
			}
			
			
			expect.fulfill()
			
		}
		.add(to: queue)
		
		wait(for: [expect], timeout: 10)

	}
	
	func testFailedSilentcondition() {
		shouldBeSuccess = false
		let expect = expectation(description: "SucceedCondition expectation")

		let operation = OperationA()
		operation.conditions(SilentCondition(SucceedOperationConditionB()))
		operation.didFinish { (result) in
			
			guard
				let error = result.error
			else {
				
				XCTAssert(false, "operation doesn't cancel for condition")
				return
			}

			guard
				error.state == .condition
			else {
				XCTAssert(false, "operation error state isn't condition")
				return
			}

			guard
				(error.publisher ?? "") == SilentCondition<SucceedOperationConditionB>.key
			else {
				
				XCTAssert(false, "operation publisher isn't \(SilentCondition<SucceedOperationConditionB>.key)")
				return
			}

			print("🚫\(error.localizedDescription)🚫")
			print("🚫\(FailedConditionError().localizedDescription)🚫")
			guard
				error.publishedError is FailedConditionError, error.localizedDescription == FailedConditionError().localizedDescription
			else {
				
				XCTAssert(false, "operation published error isn't \(String(describing: FailedConditionError.self))")
				return
			}
			
			
			expect.fulfill()
			
		}
		.add(to: queue)
		
		wait(for: [expect], timeout: 10)

		
	}

	func testSucceedNegatedCondition() {

		let expect = expectation(description: "SucceedCondition expectation")

		let operation = OperationA()
		operation.conditions(NegatedCondition(FailedCondition()))

		operation.didFinish { (result) in

			if let error = result.error,
				error.state == .condition {
				assertionFailure("operation canceled with condition error")
				return
			}

			expect.fulfill()

		}
		.add(to: queue)

		wait(for: [expect], timeout: 10)
	}

	func testFailedNegatedCondition() {
		
		let expect = expectation(description: "FailedCondition expectation")
		
		let operation = OperationA()
		operation.conditions(NegatedCondition(SucceedCondition()))
		
		operation.didFinish { (result) in
			
			guard
				let error = result.error
			else {
				
				XCTAssert(false, "operation doesn't cancel for condition")
				return
			}

			guard
				error.state == .condition
			else {
				XCTAssert(false, "operation error state isn't condition")
				return
			}

			guard
				error.publisher == NegatedCondition<SucceedCondition>.key
			else {
				
				XCTAssert(false, "operation publisher isn't \(NegatedCondition<SucceedCondition>.key)")
				return
			}

			let localizedDescription = NegatedCondition<SucceedCondition>.Error(NegatedCondition<SucceedCondition>.negatedConditionKey).localizedDescription
			
			print("🚫\(error.localizedDescription)🚫")
			print("🚫\(localizedDescription)🚫")
			guard
				error.publishedError is NegatedCondition<SucceedCondition>.Error, error.localizedDescription == localizedDescription
			else {
				
				XCTAssert(false, "operation published error isn't \(localizedDescription)")
				return
			}
			
			
			expect.fulfill()
			
		}
		.add(to: queue)
		
		wait(for: [expect], timeout: 10)
	}
	
	func testFailedNoCancelledDependencyCondition() {
		let expect = expectation(description: "FailedCondition expectation")

		let operation2 = CancellingOperation()

		let operation1 = OperationA()
		
		operation1
			.dependencies([operation2])
			.conditions(NoCanceledDependencies())
			.didFinish { (result) in
				
				guard
					let error = result.error
				else {
					
					XCTAssert(false, "operation doesn't cancel for condition")
					return
				}

				guard
					error.state == .condition
				else {
					XCTAssert(false, "operation error state isn't condition")
					return
				}

				guard
					error.publisher == NoCanceledDependencies.key
				else {
					
					XCTAssert(false, "operation publisher isn't \(NoCanceledDependencies.key)")
					return
				}

				let localizedDescription = NoCanceledDependencies.Error(canceledDependencies: [operation2.name!]).localizedDescription
				
				print("🚫\(error.localizedDescription)🚫")
				print("🚫\(localizedDescription)🚫")
				guard
					error.publishedError is NoCanceledDependencies.Error, error.localizedDescription == localizedDescription
				else {
					
					XCTAssert(false, "operation published error isn't \(localizedDescription)")
					return
				}
				
				
				expect.fulfill()
				
			}
			.add(to: queue)
			
			wait(for: [expect], timeout: 10)
	}
	
	func testSucceedNoCancelledDependencyCondition() {
		let expect = expectation(description: "FailedCondition expectation")

		let operation2 = OperationA()

		let operation1 = OperationA()
		
		operation1
			.dependencies([operation2])
			.conditions(NoCanceledDependencies())
			.didFinish { (result) in
				if let error = result.error,
					error.state == .condition {
					assertionFailure("operation canceled with condition error")
					return
				}

				expect.fulfill()
			}
			.add(to: queue)
			
			wait(for: [expect], timeout: 10)
	}
	
	func testConditionBlock() {
		let expect = expectation(description: "FailedCondition expectation")
		
		
		OperationA()
			.conditions(ConditionBlock({ (result) in
				result(.success)
			}))
			.didFinish { (result) in
				if let error = result.error,
				   error.state == .condition {
					assertionFailure("operation canceled with condition error")
					return
				}
				
				expect.fulfill()
			}
			.add(to: queue)
		
		wait(for: [expect], timeout: 10)
	}

}




fileprivate class OperationA: VoidOperation {
	
	override func execute() {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
			self.finish()
		}
	}
	
}

fileprivate struct FailedConditionError: LocalizedError {
	var errorDescription: String? {
		"Condition Failed"
	}
}

fileprivate struct SucceedCondition: AOperationCondition {
	
	var dependentOperation: AOperation? = nil
	
	static var isMutuallyExclusive: Bool = true
		
}


fileprivate struct FailedCondition: AOperationCondition {
		
	var dependentOperation: AOperation? = nil
	
	static var isMutuallyExclusive: Bool = true
	
	func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
		let error = AOperationError(FailedConditionError())
		completion(.failure(error))
	}
	
}


fileprivate struct FailedOperationCondition: AOperationCondition {
	
	var dependentOperation: AOperation? = FailedOperation()
	
	static var isMutuallyExclusive: Bool = true

}

fileprivate struct FailedOperationError: LocalizedError {
	var errorDescription: String? {
		"Operation Failed"
	}
}


fileprivate class FailedOperation: VoidOperation {
	
	static let uniqueId = UUID()

	override func execute() {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
			self.finish()
		}
		
		let error = AOperationError(FailedOperationError())
		
		self.finish(error)
	}
	
}

fileprivate struct SucceedOperationCondition: AOperationCondition {

	var dependentOperation: AOperation? = SucceedOperation()

	static var isMutuallyExclusive: Bool = true

}


var shouldBeSuccess = false

fileprivate class SucceedOperation: VoidOperation {
	
	override func execute() {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
			shouldBeSuccess = true
			self.finish()
		}
	}
	
}

fileprivate struct SucceedOperationConditionB: AOperationCondition {
	
	var dependentOperation: AOperation? = SucceedOperation()

	static var isMutuallyExclusive: Bool = true

	func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
		if shouldBeSuccess {
			completion(.success)
		}
		else {
			let error = AOperationError(FailedConditionError())
			completion(.failure(error))
		}
	}
	
}

fileprivate class CancellingOperation: VoidOperation {
	
	override func execute() {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
			self.cancel()
		}
	}

	
}


#endif
