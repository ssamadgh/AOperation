//
//  AOperation_iOS_Tests.swift
//  AOperation_iOS_Tests
//
//  Created by Seyed Samad Gholamzadeh on 3/31/19.
//

import XCTest
@testable import AOperation

class AOperation_iOS_Tests2: XCTestCase {
	
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
		let group = TestGroupOp2()
		let testGroupExpect = expectation(description: "TestGroupOperation")
		group.observeDidFinish { errors in
			print(errors)
            XCTAssertFalse(errors.isEmpty, "Should there be some erros")
			testGroupExpect.fulfill()
		}
		self.queue.addOperation(group)
		wait(for: [testGroupExpect], timeout: 30)
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


class OperationA2: AOperation {
	
	override func execute() {
		//		self.cancel()
		self.finish()
	}
}

class OperationB2: AOperation {
	
	var timer: AOperationTimer!
    weak var op3: OperationC2?
    
	override func execute() {
		if isCancelled {
			self.cancel()
			return
		}
		
		timer = AOperationTimer(interval: 0, handler: {
			print("Hello World Operation B2✅")
            self.op3?.addCondition(SampleCondition())
			self.finishWithError(nil)
		})
	}
	
}

struct SampleCondition: OperationCondition {
    static var name: String = "SampleCondition"
    
    static var isMutuallyExclusive: Bool = true
    
    func dependencyForOperation(_ operation: AOperation) -> Operation? {
        return nil
    }
    
    func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
        let error = NSError(code: .conditionFailed, userInfo: [OperationConditionKey: type(of: self).name])
        completion(.failed(error))
    }

    
}

class OperationC2: AOperation {
	
	var timer: AOperationTimer!
	
	override func execute() {
		timer = AOperationTimer(interval: 0, handler: {
			print("Hello World Operation C2🛑")
			self.finishWithError(nil)
		})
	}
}


class OperationD2: AOperation {
	
	var timer: AOperationTimer!
	
	override func execute() {
		timer = AOperationTimer(interval: 0, handler: {
			print("Hello World Operation D2 💚")
			self.finishWithError(nil)
		})
	}
}


class TestGroupOp2: GroupOperation {
	let opA: OperationA2
	let opB: OperationB2
	let opC: OperationC2
	let opD: OperationD2

	init() {
		opA = OperationA2()
		opB = OperationB2()
		opC = OperationC2()
		opD = OperationD2()

		opB.op3 = opC
		opB.addDependency(opA)
		opC.addDependency(opB)
		opD.addDependency(opC)
		let ops = [opA, opB, opC, opD]
		super.init(operations: ops)
	}
	
	override func operationDidCancel(_ operation: Operation, withErrors errors: [NSError]) {
//        errors.forEach { self.aggregateError($0) }
		self.cancel()
	}
    
    
    override func operationDidFinish(_ operation: Operation, withErrors errors: [NSError]) {
		if !errors.isEmpty {
			errors.forEach { self.aggregateError($0) }
		}
    }
    
    
    
    
	
}
