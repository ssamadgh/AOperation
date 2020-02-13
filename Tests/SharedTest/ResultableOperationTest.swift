//
//  ResultOperationTest.swift
//  AOperation_iOS_Tests
//
//  Created by Seyed Samad Gholamzadeh on 12/6/19.
//

#if os(iOS) || os(macOS) || os(tvOS)

import XCTest
import AOperation

class ResultableOperationTest: XCTestCase {

	let operationQueue = AOperationQueue()
	
	func testResultableOperationWithoutError() {
		
		let expect = expectation(description: "Test result operation with out error")
		
		let userJson =
		"""
			{
				"id" : 12,
				"name" : "samad",
				"family" : "Gholamzadeh"

			}
			
		""".data(using: .utf8)!

		
		let operation = FetchUserOperation(json: userJson)
		
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
	
	
	func testResultableOperationWithError() {
		
		let expect = expectation(description: "Test result operation with out error")
		
		let userJson =
		"""
			{
				"id" : "12",
				"name" : "samad",
				"family" : "Gholamzadeh"

			}
			
		""".data(using: .utf8)!

		
		let operation = FetchUserOperation(json: userJson)
		
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
	
	
	func testResultableOperationWithConditionError() {
		
		let expect = expectation(description: "Test result operation with out error")
		
		let userJson =
		"""
			{
				"id" : 12,
				"name" : "samad",
				"family" : "Gholamzadeh"

			}
			
		""".data(using: .utf8)!

		
		let operation = FetchUserOperation(json: userJson)
		operation.addCondition(UserSigningCondition())
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
	
	
}


fileprivate struct User: Decodable {
	let id: Int
	let name: String
	let family: String
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
            self.finish(with: .failure(operationError))
		}
	}
	
}


fileprivate struct UserSigningCondition: AOperationCondition {
	
	var dependentOperation: AOperation? = nil
	
	static var isMutuallyExclusive: Bool = false
	
	func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
		let error = AOperationError.conditionFailed(with: [.key : Self.key])
		completion(.failed(error))
	}
	
}

#endif
