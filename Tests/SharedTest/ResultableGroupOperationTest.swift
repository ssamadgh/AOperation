//
//  GroupResultableOperationTest.swift
//  AOperation_iOS_Tests
//
//  Created by Seyed Samad Gholamzadeh on 12/6/19.
//

#if os(iOS) || os(macOS) || os(tvOS)

import XCTest
import AOperation

class ResultableGroupOperationTest: XCTestCase {
	
	let operationQueue = AOperationQueue()

	func testGroupResultableOperationWithError() {
		
		let expect = expectation(description: "Test result operation with out error")
		
		let userJson =
		"""
			{
				"id" : "12",
				"name" : "samad",
				"family" : "Gholamzadeh"

			}
			
		""".data(using: .utf8)!

		let operation = FailedFetchedGroupOperation(json: userJson)
		operation.didFinishWithResult { (result) in
			
			switch result {
			case let .failure(error):
				print(error)
				expect.fulfill()
				return
			default:
				break
			}
			
			assert(false, "failed do to result does not have error")
			
		}
		
		self.operationQueue.addOperation(operation)
		wait(for: [expect], timeout: 10)
	}
	
	func testGroupResultableOperationWithJsonError() {
		
		let expect = expectation(description: "Test result operation with out error")
		
		let userJson =
		"""
			{
				"id" : "12",
				"name" : "samad",
				"family" : "Gholamzadeh"

			}
			
		""".data(using: .utf8)!

		let operation = FailedFetchedGroupOperationWithJson(json: userJson)
		operation.didFinishWithResult { (result) in
			
			switch result {
			case let .failure(error):
				print(error)
				assert(error.key == FetchUserOperation.key)
				expect.fulfill()
				return
				
			default:
				break
			}
			
			assert(false, "failed do to result does not have error")
			
		}
		
		self.operationQueue.addOperation(operation)
		wait(for: [expect], timeout: 10)
	}
	
	
	func testGroupResultableOperationWithSuccess() {
		
		let expect = expectation(description: "Test result operation with out error")
		
		let userJson =
		"""
			{
				"id" : 12,
				"name" : "samad",
				"family" : "Gholamzadeh"

			}
			
		""".data(using: .utf8)!

		
		let operation = SuccedFetchedGroupOperation(json: userJson)
		operation.didFinishWithResult { (result) in
			
			switch result {
			case let .success(user):
				guard user.name == "samad",
					user.family == "Gholamzadeh",
					user.id == 12
					else { return }
				expect.fulfill()
				return
			default:
				break
			}
			
			assert(false, "failed do to result not succeed")

		}
		
		self.operationQueue.addOperation(operation)
		wait(for: [expect], timeout: 10)
	}
	

}

fileprivate struct User: Decodable {
	let id: Int
	let name: String
	let family: String
}

fileprivate class SucceedOperation: AOperation {
		
	override func execute() {
		self.finishWithError(nil)
	}
	
}

fileprivate class FailedOperation: AOperation {
	
	static let uuid = UUID()
	
	override func execute() {
		let error = AOperationError.executionFailed(for: self, with: [.localizedDescription: "Failed operation", .reason : FailedOperation.uuid.uuidString])
		self.finishWithError(error)
	}
	
}


fileprivate class FetchUserOperation: ResultableOperation<User> {
	
	var json: Data
	
	init(json: Data) {
		self.json = json
		super.init()
	}
	
	override func execute() {
		
		do {
			
			let user = try JSONDecoder().decode(User.self, from: json)
			self.finish(with: .success(user))
			
		} catch {
			
			let operationError = AOperationError.executionFailed(with: [.key : Self.key, .localizedDescription : error.localizedDescription])
			self.finishWithError(operationError)
		}
	}
	
}

fileprivate class FailedFetchedGroupOperation: ResultableGroupOperation<User> {
	
	init(json: Data) {
		let failedOperation = FailedOperation()
		let fetchoperation = FetchUserOperation(json: json)
		super.init(operations: [failedOperation, fetchoperation])

		fetchoperation.didFinishWithResult { (result) in
			switch result {
			case .success:
				self.finish(with: result)
			default:
				break
			}
		}

		
	}
	
}

fileprivate class FailedFetchedGroupOperationWithJson: ResultableGroupOperation<User> {
	
	init(json: Data) {
		let failedOperation = SucceedOperation()
		let fetchoperation = FetchUserOperation(json: json)
		super.init(operations: [failedOperation, fetchoperation])

		fetchoperation.didFinishWithResult { (result) in
			switch result {
			case .success:
				self.finish(with: result)
			default:
				break
			}
		}

		
	}
	
}



fileprivate class SuccedFetchedGroupOperation: ResultableGroupOperation<User> {
	
	init(json: Data) {
		let succeedOperation = SucceedOperation()
		let fetchoperation = FetchUserOperation(json: json)
		super.init(operations: [succeedOperation, fetchoperation])
		
		fetchoperation.didFinishWithResult { (result) in
			switch result {
			case .success:
				self.finish(with: result)
			default:
				break
			}
		}

	}
	
}

#endif
