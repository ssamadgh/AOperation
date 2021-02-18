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

	let queue = AOperationQueue()
	
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
		AOperation.Debugger.printOperationsState = true
    }


	func testAddingTwoRegularOperations() {
		let expect = expectation(description: "test regular operaions")
		expect.expectedFulfillmentCount = 2
		
		RegularOperationA().didFinish { (result) in
			expect.fulfill()
		}
		.add(to: queue)
		
		RegularOperationA().didFinish { (errors) in
			expect.fulfill()
		}
		.add(to: queue)

		wait(for: [expect], timeout: 10)
	}
	
	func testAddingOneRegularOperationsAndOneUnique() {

		let expect = expectation(description: "test one regular and one unique operaions")
		expect.expectedFulfillmentCount = 2
		
		UniqueOperationA().didFinish { (errors) in
			expect.fulfill()
		}
		.add(to: queue)

		RegularOperationA().didFinish { (errors) in
			expect.fulfill()
		}
		.add(to: queue)

		wait(for: [expect], timeout: 10)
	}
	
	func testAddingTwoUniqueOperations() {
		let expect = expectation(description: "test two unique operaions")
		expect.expectedFulfillmentCount = 1
		expect.assertForOverFulfill = true
		
		UniqueOperationA().didFinish { (errors) in
			expect.fulfill()
		}
		.add(to: queue)

		UniqueOperationA().didFinish { (errors) in
			expect.fulfill()
		}
		.add(to: queue)

		wait(for: [expect], timeout: 10)
	}
	

}


fileprivate class RegularOperationA: VoidOperation {
	
	override init() {
		super.init()
	}
	
	override func execute() {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
		self.finish()
		}
	}
	
}

fileprivate class UniqueOperationA: VoidOperation, UniqueOperation {
	
	var uniqueId: String = "Extremely Unique"
	
	override init() {
		super.init()
	}
	
	override func execute() {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
		self.finish()
		}
	}
	
}

#endif
