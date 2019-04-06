//
//  AOperation_iOS_Tests.swift
//  AOperation_iOS_Tests
//
//  Created by Seyed Samad Gholamzadeh on 3/31/19.
//

import XCTest
@testable import AOperation

class AOperation_iOS_Tests: XCTestCase {
	
	let queue = AOperationQueue()
	var timer: AOperationTimer!
	
	override func setUp() {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		AOperationDebugger.printOperationsState = true
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testOperationTimer() {
		let timerExpect = expectation(description: "Timer execution")
		timer = AOperationTimer(interval: 2) {
			print("Timer executed")
			timerExpect.fulfill()
		}
		
		wait(for: [timerExpect], timeout: 5)
		
	}
	
	func testOperationGroup() {
		let group = TestGroupOp()
		let testGroupExpect = expectation(description: "TestGroupOperation")
		group.observeDidFinish { errors in
			
			testGroupExpect.fulfill()
		}
		self.queue.addOperation(group)
		wait(for: [testGroupExpect], timeout: 3)
	}
	
	func testCancelBeforeExecuteOperation() {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		let expect = expectation(description: "TestGroupOperation")
		let opB = OperationB()
		opB.observeDidCancel { (errors) in
			print("Cancelled 📛")
		}
		opB.observeDidFinish { errors in
			print("finished ✅")
			expect.fulfill()
		}

		opB.cancel()
		self.queue.addOperation(opB)
		wait(for: [expect], timeout: 3)
	}
		
	func testPerformanceExample() {
		// This is an example of a performance test case.
		self.measure {
			// Put the code you want to measure the time of here.
		}
	}
	
}


class OperationA: AOperation {
	
	override func execute() {
		//		self.cancel()
		self.finish()
	}
}

class OperationB: AOperation {
	
	var timer: AOperationTimer!
	
	override func execute() {
		if isCancelled {
			self.cancel()
			return
		}
		
		timer = AOperationTimer(interval: 0, handler: {
			print("Hello World Operation B✅")
			self.finishWithError(nil)
		})
	}
	
}

class OperationC: AOperation {
	
	var timer: AOperationTimer!
	
	override func execute() {
		timer = AOperationTimer(interval: 0, handler: {
			print("Hello World Operation C🛑")
			self.finishWithError(nil)
		})
	}
}

class TestGroupOp: GroupOperation {
	let opA: OperationA
	let opB: OperationB
	let opC: OperationC
	
	init() {
		opA = OperationA()
		opB = OperationB()
		opC = OperationC()
		
		opB.addDependency(opA)
		opC.addDependency(opB)
		
		let ops = [opA, opB, opC]
		super.init(operations: ops)
	}
	
	override func operationDidCancel(_ operation: Operation, withErrors errors: [NSError]) {
		self.cancel()
	}
	
}
