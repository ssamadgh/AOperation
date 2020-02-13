//
//  OrderedGroupResultableOperationTest.swift
//  AOperation_iOS_Tests
//
//  Created by Seyed Samad Gholamzadeh on 12/6/19.
//

#if os(iOS) || os(macOS) || os(tvOS)

import XCTest
import AOperation

class ResultableOrderedGroupOperationTest: XCTestCase {
    
    let operationQueue = AOperationQueue()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testOrderedGroupResultableOperationWithFirstFailedOperation() {
        let expect = expectation(description: "testOrderedGroupResultableOperationWithFirstFailedOperation")
        let operation = ResultableOrderedGroupOperation<Any>(operations: [FirstFailedOperation(), SecondFailedOperation()])
        
        operation.didFinishWithResult { (result) in
            
            switch result {
            case let .failure(error):
                assert(error.failureReason == FirstFailedOperation.uuid.uuidString)
                expect.fulfill()
                
            default:
                break
            }
            
        }
        
        self.operationQueue.addOperation(operation)
        wait(for: [expect], timeout: 10)
    }
    
    func testOrderedGroupResultableOperationWithSecondFailedOperation() {
        let expect = expectation(description: "testOrderedGroupResultableOperationWithFirstFailedOperation")
        let operation = ResultableOrderedGroupOperation<Any>(operations: [SecondFailedOperation(), FirstFailedOperation()])
        
        operation.didFinishWithResult { (result) in
            
            switch result {
            case let .failure(error):
                assert(error.failureReason == SecondFailedOperation.uuid.uuidString)
                expect.fulfill()
                
            default:
                break
            }
            
        }
        
        self.operationQueue.addOperation(operation)
        wait(for: [expect], timeout: 10)
    }
    
}

fileprivate class FirstFailedOperation: AOperation {
	
	static let uuid = UUID()
	
	override func execute() {
		let error = AOperationError.executionFailed(for: self, with: [.localizedDescription: "Failed operation", .reason : FirstFailedOperation.uuid.uuidString])
		self.finishWithError(error)
	}
	
}


fileprivate class SecondFailedOperation: AOperation {
	
	static let uuid = UUID()
	
	override func execute() {
		let error = AOperationError.executionFailed(for: self, with: [.localizedDescription: "Failed operation", .reason : SecondFailedOperation.uuid.uuidString])
		self.finishWithError(error)
	}
	
}


#endif
