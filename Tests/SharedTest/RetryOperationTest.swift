//
//  RetryOperationTest.swift
//  AOperation_iOS_Tests
//
//  Created by Seyed Samad Gholamzadeh on 1/1/21.
//

import XCTest
import AOperation

class RetryOperationTest: XCTestCase {
	
	let queue = AOperationQueue()
	
	override class func setUp() {
		AOperation.Debugger.printOperationsState = true
	}
	
	func testRetryForOnceOperationA() {
		_opACounter = 0
		let expect = expectation(description: "Test Retry OperationA")
		expect.expectedFulfillmentCount = 3
		
		OperationA()
			.retryOnFailure { (numberOfRetries, error, retry) in
				expect.fulfill()
				switch numberOfRetries {
				case 0:
					retry(true)
				default:
					retry(false)
				}
			}
			.didFinish { (result) in
				XCTAssertNotNil(result.error, "result should produce error")
				expect.fulfill()
			}
			.add(to: queue)
		wait(for: [expect], timeout: 100)
	}
	
	func testRetryForTwiceOperationA() {
		_opACounter = 0
		let expect = expectation(description: "Test Retry OperationA")
		expect.expectedFulfillmentCount = 4
		
		OperationA()
			.retryOnFailure { (numberOfRetries, error, retry) in
				expect.fulfill()
				switch numberOfRetries {
				case 0, 1:
					retry(true)
				default:
					retry(false)
				}
			}
			.didFinish { (result) in
				XCTAssertNotNil(result.error, "result should produce error")
				expect.fulfill()
			}
			.add(to: queue)
		wait(for: [expect], timeout: 100)
	}
	
	func testRetryOperationAUntilBeTrue() {
		_opACounter = 0
		let expect = expectation(description: "Test Retry OperationA")
		
		OperationA()
			.retryOnFailure { (numberOfRetries, error, retry) in
				retry(true)
			}
			.didFinish { (result) in
				XCTAssertNil(result.error, "result shouldn't produce error")
				expect.fulfill()
			}
			.add(to: queue)
		wait(for: [expect], timeout: 100)
	}
	
	func testRetryOperationWithOneDependency() {
		_opACounter = 0
		let expect = expectation(description: "Test Retry OperationA")
		
		OperationA()
			.deliver(to: OperationB())
			.retryOnFailure { (numberOfRetries, error, retry) in
				retry(true)
			}
			.didFinish { (result) in
				XCTAssertNil(result.error, "result shouldn't produce error")
				expect.fulfill()
			}
			.add(to: queue)
		wait(for: [expect], timeout: 20)
	}
	
	func testRetryOperationWithChainedDependency() {
		_opACounter = 0
		_opBCounter = 0
		_opCCounter = 0
		_opDCounter = 0
		_opECounter = 0
		let expect = expectation(description: "Test Retry OperationA")
		expect.assertForOverFulfill = true
		expect.expectedFulfillmentCount = 4
		OperationC()
			.deliver(to: OperationD())
			.deliver(to: OperationE())
			.retryOnFailure { (numberOfRetries, error, retry) in
				print("AOperation number of retries is \(numberOfRetries)")
				print("AOperation errorPublisher is \(error.publisher ?? "")")
				switch numberOfRetries {
				case 0:
					XCTAssert(error.publisher == OperationC.key)
				case 1:
					XCTAssert(error.publisher == OperationD.key)
				case 2:
					XCTAssert(error.publisher == OperationE.key)
				default:
					break
				}
				expect.fulfill()
				retry(true)
			}
			.didFinish { (result) in
				XCTAssertNil(result.error, "result shouldn't produce error")
				expect.fulfill()
			}
			.add(to: queue)
		wait(for: [expect], timeout: 20)
	}
	
	
	
	
}

struct TestError: LocalizedError {
	var errorDescription: String? {
		"unknown error"
	}
}


fileprivate var _opACounter: Int = 0

fileprivate var opACount: Int {
	get {
		let count = _opACounter
		_opACounter += 1
		return count
	}
}

fileprivate class OperationA: ResultableOperation<String>, RetryableOperation {
	
	func new() -> Self {
		OperationA() as! Self
	}
	
	override func execute() {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
			if opACount > 3 {
				self.finish(with: .success("Finished"))
			}
			else {
				self.finish(with: .failure(AOperationError(TestError())))
			}
		}
	}
	
}

fileprivate var _opBCounter: Int = 0

fileprivate var opBCount: Int {
	get {
		let count = _opBCounter
		_opBCounter += 1
		return count
	}
}

fileprivate class OperationB: ResultableOperation<String>, RetryableOperation, ReceiverOperation {
	
	func new() -> Self {
		OperationB() as! Self
	}
	
	var receivedValue: Result<String, AOperationError>?
	
	override func execute() {
		guard let value = self.receivedValue else {
			self.finish(with: .failure(.receivedValueIsNil(in: self)))
			return
		}

		switch value {
		case .success:
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
				self.finish(with: .success("Finished"))
			}
			
		case .failure(let error):
			self.finish(with: .failure(error))
		}
	}
	
}

fileprivate var _opCCounter: Int = 0

fileprivate var opCCount: Int {
	get {
		let count = _opCCounter
		_opCCounter += 1
		return count
	}
}

fileprivate class OperationC: ResultableOperation<String>, RetryableOperation, ReceiverOperation {
	
	func new() -> Self {
		OperationC() as! Self
	}
	
	var receivedValue: Result<String, AOperationError>?
	
	override func execute() {
		guard let value = receivedValue else {
			if opCCount > 0 {
				self.finish(with: .success("Finished"))
			}
			else {
				self.finish(with: .failure(AOperationError(TestError())))
			}
			return
		}
		
		switch value {
		case .success:
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
				if opCCount > 0 {
					self.finish(with: .success("Finished"))
				}
				else {
					self.finish(with: .failure(AOperationError(TestError())))
				}
			}
			
		case .failure(let error):
			self.finish(with: .failure(error))
		}
	}
	
}

fileprivate var _opDCounter: Int = 0

fileprivate var opDCount: Int {
	get {
		let count = _opDCounter
		_opDCounter += 1
		return count
	}
}

fileprivate class OperationD: ResultableOperation<String>, RetryableOperation, ReceiverOperation {
	
	func new() -> Self {
		let op = OperationD() as! Self
		op.receivedValue = receivedValue
		return op
	}
	
	var receivedValue: Result<String, AOperationError>?
	
	override func execute() {
		guard let value = self.receivedValue else {
			self.finish(with: .failure(.receivedValueIsNil(in: self)))
			return
		}

		switch value {
		case .success:
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
				if opDCount > 0 {
					self.finish(with: .success("Finished"))
				}
				else {
					self.finish(with: .failure(AOperationError(TestError())))
				}
			}
			
		case .failure(let error):
			self.finish(with: .failure(error))
		}
	}
	
}

fileprivate var _opECounter: Int = 0

fileprivate var opECount: Int {
	get {
		let count = _opECounter
		_opECounter += 1
		return count
	}
}

fileprivate class OperationE: ResultableOperation<String>, RetryableOperation, ReceiverOperation {
	
	func new() -> Self {
		OperationE() as! Self
	}
	
	var receivedValue: Result<String, AOperationError>?
	
	override func execute() {
		guard let value = receivedValue else {
			if opECount > 0 {
				self.finish(with: .success("Finished"))
			}
			else {
				self.finish(with: .failure(AOperationError(TestError())))
			}
			return
		}
		
		switch value {
		case .success:
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
				if opECount > 0 {
					self.finish(with: .success("Finished"))
				}
				else {
					self.finish(with: .failure(AOperationError(TestError())))
				}
			}
			
		case .failure(let error):
			self.finish(with: .failure(error))
		}
	}
	
}
