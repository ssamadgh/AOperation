//
//  DeliverToOperationTest.swift
//  AOperation_iOS_Tests
//
//  Created by Seyed Samad Gholamzadeh on 1/1/21.
//

import XCTest
@testable import AOperation

class DeliverToOperationTest: XCTestCase {

	let queue = AOperationQueue()

	func testMapOperation() throws {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		
		MapOperationBlock<Void, Int> { _, finish in
			finish(.success(32))
		}
		.deliver(to: MapOperationBlock<Int, String> { received, finish in
			let valeu = try! received!.get()
			finish(.success(String(valeu)))
		})
		.didFinish { (result) in
			switch result {
			case .success(let value):
				XCTAssert(value == "32")
				expect.fulfill()
			case .failure:
				XCTAssert(false, "Should not be failed")
			}
		}
		.add(to: queue)
		wait(for: [expect], timeout: 10)
		
	}
	
	func testReceivingResultFromURLSessionTaskOperation() throws {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: "MOCK_DATA_10", withExtension: "json")!
		
		let request = URLRequest(url: url)
		
		URLSessionTaskOperation.data(for: request)
			.didFinish({ (result) in
				switch result {
				case let .success:
					expect.fulfill()
				case .failure:
					XCTAssert(false, "Should not be failed")
				}
			})
			.add(to: queue)
		wait(for: [expect], timeout: 10)
		
	}
	
	
    func testConveringReceivedDataToModelWithDeliverToOperation() throws {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: "MOCK_DATA_10", withExtension: "json")!

		let request = URLRequest(url: url)

		URLSessionTaskOperation.data(for: request)
			.deliver(to: JsonDecodeOperation<[User]>())
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
	
	func testConveringReceivedDataToDicWithDeliverToOperation() throws {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: "MOCK_DATA_10", withExtension: "json")!

		let request = URLRequest(url: url)

		URLSessionTaskOperation.data(for: request)
			.deliver(to: JsonDecodeOperation<[User]>())
			.deliver(to: MakeDictionaryOperation())
			.didFinish({ (result) in
				switch result {
				case let .success(dic):
					XCTAssertEqual(dic.count, 10)
					expect.fulfill()
				case .failure(let error):
					XCTAssert(false, "Should not be failed \(error)")
				}
			})
		.add(to: queue)
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


fileprivate class JsonDecodeOperation<Output: Decodable>: ResultableOperation<Output>, ReceiverOperation {
	
	var receivedValue: Result<(Data, URLResponse), AOperationError>?
			
	override func execute() {
		guard let value = self.receivedValue else {
			self.finish(with: .failure(.receivedValueIsNil(in: self)))
			return
		}
		
		do {
			
			switch value {
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
	
	struct Error: LocalizedError {
		public var errorDescription: String? {
			"Fetch User Failed"
		}
	}
	
}

fileprivate class MakeDictionaryOperation: ResultableOperation<[Int: User]>, ReceiverOperation {
	
	var receivedValue: Result<[User], AOperationError>?
	
	override func execute() {
		guard let value = receivedValue else {
			self.finish(with: .failure(.receivedValueIsNil(in: self)))
			return
		}
		
		switch value {
		case let .success(users):
			let dic = Dictionary(sequence: users) { $0.id }
			self.finish(with: .success(dic))
		case let .failure(error):
			self.finish(with: .failure(error))
		}
	}
	
}

extension MakeDictionaryOperation {
	struct Error: LocalizedError {
		var errorDescription: String? {
			"received error is nil"
		}
	}
}

