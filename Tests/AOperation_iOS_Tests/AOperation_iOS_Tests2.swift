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
	
    func testOperationCondition() {
        let expect = expectation(description: "TestGroupOperation")

        let operation = OperationC2()
        operation.addCondition(SampleCondition())
        operation.observeDidFinish { (errors) in
            print("Condition error is \(errors)")
            expect.fulfill()
        }
        self.queue.addOperation(operation)
        wait(for: [expect], timeout: 10)
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
        opB.addCondition(SampleCondition())
		opB.observeDidFinish { errors in
            print(errors)
			if opB.isCancelled {
				print("Canceled 🔴")
			}
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
            
			self.finishWithError(nil)
		})
	}
	
}

struct SampleCondition: AOperationCondition {
    
    var dependentOperation: AOperation? = SampleConditionOperation()

    static var key: String = "SampleCondition"
    
    static var isMutuallyExclusive: Bool = true

    
}

class SampleConditionOperation: AOperation {
    
    override func execute() {
        let error = AOperationError.conditionFailed(with: [.key: SampleCondition.key, .localizedDescription : "Please see this sample and judge about it"])
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.finishWithError(error)
        }
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
	

    
    
	override func operationDidFinish(_ operation: Operation, withErrors errors: [AOperationError]) {
		
		if !errors.isEmpty {
			errors.forEach { self.aggregateError($0) }
		}
		
		if operation.isCancelled {
			self.cancel()
		}
		
	}
    
    
    
    
	
}
