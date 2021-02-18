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
	
	let queue = AOperationQueue()
	
	func testResultableOperationWithoutError() {
		
		let expect = expectation(description: "Test result operation with out error")
		
		let userJson =
			"""
			{
				"id" : 12,
				"name" : "Seyed Samad",
				"family" : "Gholamzadeh"

			}
			
		""".data(using: .utf8)!
		
		
		FetchUserOperation(json: userJson)
			.didFinish { (result) in
				
				switch result {
				case let .success(user):
					guard user.name == "Seyed Samad",
						  user.family == "Gholamzadeh",
						  user.id == 12
					else { return }
					expect.fulfill()
					return
				case .failure:
					XCTAssert(false, "failed do to result not succeed")
				}
				
			}
			.add(to: queue)
		
		wait(for: [expect], timeout: 10)
	}
	
	
	func testResultableOperationWithError() {
		
		let expect = expectation(description: "Test result operation with error")
		
		let userJson =
			"""
			{
				"id" : "12",
				"name" : "samad",
				"family" : "Gholamzadeh"

			}
			
		""".data(using: .utf8)!
		
		
		FetchUserOperation(json: userJson)
			.didFinish { (result) in
				
				switch result {
				case .success:
					XCTAssert(false, "failed do to result does not have error")

				case let .failure(error):
					XCTAssert(error.publishedError is FetchUserOperation.Error)
					expect.fulfill()
					return
				}
				
				
			}
			.add(to: queue)
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
		
		
		FetchUserOperation(json: userJson)
			.conditions(UserSigningCondition())
			.didFinish{ (result) in
				
				switch result {
				case .success:
					XCTAssert(false, "failed do to result does not have error")

				case let .failure(error):
					XCTAssert(error.publishedError is UserSigningCondition.Error)
					expect.fulfill()
				}
				
			}
			.add(to: queue)
		
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
			
			let operationError = AOperationError(Error())
			self.finish(with: .failure(operationError))
		}
	}
	
}

extension FetchUserOperation {
	
	public struct Error: LocalizedError {
		public var errorDescription: String? {
			"Fetch User Failed"
		}
	}
	
}



fileprivate struct UserSigningCondition: AOperationCondition {
		
	var dependentOperation: AOperation? = nil
	
	static var isMutuallyExclusive: Bool = false
	
	func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
		let error = AOperationError(Error())
		completion(.failure(error))
	}
	
}

extension UserSigningCondition {
	
	public struct Error: LocalizedError {
		public var errorDescription: String? {
			"User Signing Failed"
		}
	}
}

#endif
