//
//  VoidOperationTest.swift
//  AOperation_iOS_Tests
//
//  Created by Seyed Samad Gholamzadeh on 1/1/21.
//

#if os(iOS) || os(macOS) || os(tvOS)

import XCTest
import AOperation

class VoidOperationTest: XCTestCase {

	let operationQueue = AOperationQueue()

	
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFinishingVoidOperation() throws {
		let expect = expectation(description: "Test Canceling OperationA")

		OperationA().didFinish { (_) in
			expect.fulfill()
		}
		.add(to: operationQueue)
		wait(for: [expect], timeout: 10)
	}

}

fileprivate class OperationA: VoidOperation {
	
	override func execute() {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
			self.finish()
		}
	}
	
}

#endif
