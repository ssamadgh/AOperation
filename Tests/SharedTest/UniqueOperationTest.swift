//
//  UniqueOperationTest.swift
//  AOperation_iOS_Tests
//
//  Created by Seyed Samad Gholamzadeh on 12/6/19.
//

#if os(iOS) || os(macOS) || os(tvOS)

import XCTest
import AOperation

class UniqueOperationTest: XCTestCase {

	let operationQueue = AOperationQueue()
	
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
		AOperation.Debugger.printOperationsState = true
    }


	func testAddingTwoRegularOperations() {
		
		let firstOperation = TestRegularOperation()
		let secondOperation = TestRegularOperation()

		let expect = expectation(description: "test regular operaions")
		expect.expectedFulfillmentCount = 2
		expect.assertForOverFulfill = true
		
		firstOperation.didFinish { (errors) in
			expect.fulfill()
		}
		
		secondOperation.didFinish { (errors) in
			expect.fulfill()
		}

		
		self.operationQueue.addOperation(firstOperation)
		self.operationQueue.addOperation(secondOperation)

		wait(for: [expect], timeout: 10)
	}
	
	func testAddingTwoRegularOperationsWhichOneSetUnique() {
		
		let firstOperation = TestUniqueOperation()
		let secondOperation = TestRegularOperation()

		let expect = expectation(description: "test unique operaions")
		expect.expectedFulfillmentCount = 2
		expect.assertForOverFulfill = true
		
		firstOperation.didFinish { (errors) in
			expect.fulfill()
		}
		
		secondOperation.didFinish { (errors) in
			expect.fulfill()
		}

		
		self.operationQueue.addOperation(firstOperation)
		self.operationQueue.addOperation(secondOperation)

		wait(for: [expect], timeout: 10)
	}
	
	func testAddingTwoUniqueOperations() {
		
		let firstOperation = TestUniqueOperation()
		let secondOperation = TestUniqueOperation()

		let expect = expectation(description: "test unique operaions")
		expect.expectedFulfillmentCount = 1
		expect.assertForOverFulfill = true
		
		firstOperation.didFinish { (errors) in
			expect.fulfill()
		}
		
		secondOperation.didFinish { (errors) in
			expect.fulfill()
		}

		
		self.operationQueue.addOperation(firstOperation)
		self.operationQueue.addOperation(secondOperation)

		wait(for: [expect], timeout: 10)
	}
	

}


fileprivate class TestRegularOperation: AOperation {
	
	override init() {
		super.init()
	}
	
	override func execute() {
		self.finishWithError(nil)
	}
	
}

fileprivate class TestUniqueOperation: AOperation, UniqueOperation {
	
	var uniqueId: String = "Extremely Unique"
	
	override init() {
		super.init()
	}
	
	override func execute() {
		self.finishWithError(nil)
	}
	
}

#endif
