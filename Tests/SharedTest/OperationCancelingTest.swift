//
//  TestCancelingOperation.swift
//  AOperation_iOS_Tests
//
//  Created by Seyed Samad Gholamzadeh on 2/15/20.
//

#if os(iOS) || os(macOS) || os(tvOS)

import XCTest
import AOperation

class OperationCancelingTest: XCTestCase {

    let operationQueue = AOperationQueue()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        AOperation.Debugger.printOperationsState = true
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testCancelingASimpleOperation() {
		let expect = expectation(description: "Test Canceling OperationA")
		
		let operation = OperationA()
		
		operation.didFinish { (result) in
			let error = result.error
			XCTAssertNotNil(error)
			XCTAssert(error!.publishedError is AOperationError.IsCancelled)
			expect.fulfill()
		}.add(to: operationQueue)
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
			operation.cancel()
		}
		wait(for: [expect], timeout: 10)
	}
	
	func testCancelingAOperationBlockBeforeAddingToQueue() {
		let expect = expectation(description: "Test result operation with out error")
		let blockOperaiton = AOperationBlock {
			print("Im executed")
			XCTAssert(false, "This line do not must executes")
		}.didFinish { (result) in
			let error = result.error
			XCTAssertNotNil(error)
			XCTAssert(error!.publishedError is AOperationError.IsCancelled)
			expect.fulfill()
		}
		blockOperaiton.cancel()
		blockOperaiton.add(to: operationQueue)
		wait(for: [expect], timeout: 100)
	}

	
	func testCancelingAOperationBlockAfterAddingToQueue() {
		let expect = expectation(description: "Test result operation with out error")
		let blockOperaiton = AOperationBlock {
			print("Im executed")
			XCTAssert(false, "This line do not must executes")
		}.didFinish { (result) in
			let error = result.error
			XCTAssertNotNil(error)
			XCTAssert(error!.publishedError is AOperationError.IsCancelled)
			expect.fulfill()
		}
		blockOperaiton.add(to: operationQueue)
		blockOperaiton.cancel()
		wait(for: [expect], timeout: 100)
	}
	
	func testCancelingAOperationBlockAfterExecute() {
		let expect = expectation(description: "Test result operation with out error")
		var operation: AOperation?
		let blockOperaiton = AOperationBlock {
			operation?.cancel()
		}.didFinish { (result) in
			let error = result.error
			XCTAssertNotNil(error)
			XCTAssert(error!.publishedError is AOperationError.IsCancelled)
			expect.fulfill()
		}
		operation = blockOperaiton
		blockOperaiton.add(to: operationQueue)
		wait(for: [expect], timeout: 100)
	}


	func testCancelingGroupWithBlock() {
		let expect = expectation(description: "Test result operation with out error")
		expect.expectedFulfillmentCount = 3

		let delayOperation = DelayOperation<Void>(10).didFinish { (result) in
			let error = result.error
			XCTAssertNotNil(error)
			XCTAssert(error!.publishedError is AOperationError.IsCancelled)
			expect.fulfill()
		}

		let blockOperaiton = AOperationBlock { finish in
			print("Im executed 😁")
		}.didFinish { (result) in
			let error = result.error
			XCTAssertNotNil(error)
			XCTAssert(error!.publishedError is AOperationError.IsCancelled)
			expect.fulfill()
		}

		let orderedGroupOperation = GroupOperation([delayOperation, blockOperaiton]).didFinish { (result) in
			let error = result.error
			XCTAssertNotNil(error)
			XCTAssert(error!.publishedError is AOperationError.IsCancelled)
			expect.fulfill()
		}.add(to: operationQueue)

		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
			orderedGroupOperation.cancel()
		}


		self.operationQueue.addOperation(orderedGroupOperation)
		wait(for: [expect], timeout: 100)

	}
	
    func testCancelingOrderedGroupWithBlock() {
        let expect = expectation(description: "Test result operation with out error")
		expect.expectedFulfillmentCount = 3

		let delayOperation = DelayOperation<Void>(TimeInterval(10)).didFinish { (result) in
			let error = result.error
			XCTAssertNotNil(error)
			XCTAssert(error!.publishedError is AOperationError.IsCancelled)
			expect.fulfill()
		}

        let blockOperaiton = AOperationBlock {
            print("Im executed 😁")
			XCTAssert(false, "This line should not be executes")
        }.didFinish { (result) in
			let error = result.error
			XCTAssertNotNil(error)
			XCTAssert(error!.publishedError is AOperationError.IsCancelled)
			expect.fulfill()
		}

		let orderedGroupOperation = OrderedGroupOperation([delayOperation, blockOperaiton]).didFinish { (result) in
			let error = result.error
			XCTAssertNotNil(error)
			XCTAssert(error!.publishedError is AOperationError.IsCancelled)
			expect.fulfill()
		}.add(to: operationQueue)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            orderedGroupOperation.cancel()
        }


        self.operationQueue.addOperation(orderedGroupOperation)
        wait(for: [expect], timeout: 100)

    }

}

fileprivate class OperationA: VoidOperation {
	
	override func execute() {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
			self.finish()
		}
	}
	
}

#endif
