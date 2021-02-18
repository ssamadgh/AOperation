//
//  OperationStatesTest.swift
//  AOperation_iOS_Tests
//
//  Created by Seyed Samad Gholamzadeh on 12/25/20.
//

import XCTest
@testable import AOperation

class OperationObserversTest: XCTestCase {

	let queue = AOperationQueue()

	
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testOperationDidStart() throws {
		let expect = expectation(description: "Expect the operation finish")
		expect.expectedFulfillmentCount = 3
		let operation = OperationA()
		operation.didStart {
			XCTAssertTrue(operation.isExecuting)
			XCTAssertFalse(operation.isFinished)
			expect.fulfill()
		}.willFinish({ (_, finish) in
			XCTAssertTrue(operation.isExecuting)
			XCTAssertFalse(operation.isFinished)
			expect.fulfill()
			finish()
		}).didFinish({ (_) in
			XCTAssertTrue(operation.isFinished)
			expect.fulfill()
		}).add(to: queue)
		wait(for: [expect], timeout: 5)
	}	
	

}


fileprivate class OperationA: VoidOperation {
	
	override func execute() {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
			self.finish()
		}
	}
	
}
