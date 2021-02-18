//
//  GroupResultableOperationTest.swift
//  AOperation_iOS_Tests
//
//  Created by Seyed Samad Gholamzadeh on 12/6/19.
//

#if os(iOS) || os(macOS) || os(tvOS)

import XCTest
import AOperation

class WrapperOperationTest: XCTestCase {
	
	let queue = AOperationQueue()
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testUsingWrapperOperationWithoutOperation() throws {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		let operation = WrapperOperation<Void, Void> { (received) -> ResultableOperation<Void>? in
			nil
		}
		operation.addObserver(BlockObserver(startHandler: nil, produceHandler: nil, finishHandler: { (operation, errors) in
			expect.fulfill()
		}))
		operation.add(to: queue)
		wait(for: [expect], timeout: 10)
	}

	func testUsingWrapperOperationToDecodeServiceURL() throws {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: "MOCK_DATA_10", withExtension: "json")!
		
		let request = URLRequest(url: url)
		
		ServiceDecodeOperation<[User]>(request)
			.didFinish({ (result) in
				switch result {
				case let .success(users):
					XCTAssertEqual(users.count, 10)
					expect.fulfill()
				case .failure:
					XCTAssert(false, "Should not be failed")
				}
			})
			.add(to: queue)
		wait(for: [expect], timeout: 10)
	}
	
	func testCancelingWrapperOperation() throws {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")

		let operation = WrapperOperation<Void, Void> { (received) -> OperationA? in
			OperationA()
		}
		.didFinish { (result) in
			let error = result.error
			XCTAssertNotNil(error)
			XCTAssert(error!.publishedError is AOperationError.IsCancelled)
			expect.fulfill()
		}
		.add(to: queue)
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
			operation.cancel()
		}
		wait(for: [expect], timeout: 10)

	}
	
}

fileprivate struct User: Decodable {
	var id: Int
	var firstName: String
	var lastName: String
	var fullName: String {
		return firstName + " " + lastName
	}
}

fileprivate class OperationA: VoidOperation {
	
	override func execute() {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) {
			self.finish()
		}
	}
	
}

fileprivate class ServiceDecodeOperation<Output: Decodable>: WrapperOperation<Void, Output> {
	
	init(_ request: URLRequest) {
		super.init { (_) -> ResultableOperation<Output>? in
			URLSessionTaskOperation.data(for: request)
				.deliver(to: JsonDecodeOperation<Output>())
		}
	}
	
}


fileprivate class JsonDecodeOperation<Output: Decodable>: ResultableOperation<Output>, ReceiverOperation {
	
	var receivedValue: Result<(Data, URLResponse), AOperationError>?
			
	override func execute() {

		guard let input = receivedValue else {
			self.finish(with: .failure(.receivedValueIsNil(in: self)))
			return
		}
		
		do {
			
			switch input {
			case let .success((data,_)):
				let output = try JSONDecoder().decode(Output.self, from: data)
				self.finish(with: .success(output))
			case .failure(let error):
				self.finish(with: .failure(error))
				return
			}
			
		} catch {
			
			let operationError = AOperationError(Error())
			self.finish(with: .failure(operationError))
		}
	}
	
}

extension JsonDecodeOperation {
	
	public struct Error: LocalizedError {
		public var errorDescription: String? {
			"Fetch User Failed"
		}
	}
	
}

#endif
