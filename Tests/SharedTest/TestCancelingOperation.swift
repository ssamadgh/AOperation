//
//  TestCancelingOperation.swift
//  AOperation_iOS_Tests
//
//  Created by Seyed Samad Gholamzadeh on 2/15/20.
//

#if os(iOS) || os(macOS) || os(tvOS)

import XCTest
import AOperation

class TestCancelingOperation: XCTestCase {

    let operationQueue = AOperationQueue()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        AOperation.Debugger.printOperationsState = true
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCancelingGroupWithBlock() {
        let expect = expectation(description: "Test result operation with out error")

        let delayOperation = DelayOperation(interval: TimeInterval(10))
        let blockOperaiton = BlockAOperation {
            print("Im executed")
            assert(false, "This line do not must executes")
        }
        let orderedGroupOperation = OrderedGroupOperation(operations: [delayOperation, blockOperaiton])
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            orderedGroupOperation.cancel()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            expect.fulfill()
        }

        
        self.operationQueue.addOperation(orderedGroupOperation)
        wait(for: [expect], timeout: 10)
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}


#endif
