//
//  PublisherOperationTest.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 1/12/21.
//

import XCTest
import AOperation
import UIKit
import Combine

@available(iOS 13.0, *)
class PublisherOperationTest: XCTestCase {
	
	let queue = AOperationQueue()
	
	var usersSubscriber: AnyCancellable?
	
	@Published var username: String = ""
	
	@Published var textField: UITextField!
	
	
	override class func setUp() {
		AOperation.Debugger.printOperationsState = true
	}
	
	func testSinkUserSubscriberSucceed() {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: "MOCK_DATA_10", withExtension: "json")!
		
		let request = URLRequest(url: url)
		
		usersSubscriber = URLSessionTaskOperation.data(for: request)
			.publisher(on: queue)
			.sink { (completion) in
				switch completion {
				case .finished:
					break
				case .failure(let error):
					XCTAssert(false, "\(error)")
				}
			} receiveValue: { (users) in
				expect.fulfill()
			}
		
		wait(for: [expect], timeout: 30)
	}
	
	func testSinkUserSubscriberFailure() {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		let url = URL(string: "https://WrongAddress.com")!
		
		let request = URLRequest(url: url)
		
		usersSubscriber = URLSessionTaskOperation.data(for: request)
			.publisher(on: queue)
			.sink { (completion) in
				switch completion {
				case .finished:
					XCTAssert(false, "Should not be succeed")
				case .failure:
					expect.fulfill()
				}
			} receiveValue: { (users) in
				XCTAssert(false, "Should not be called because of failure")
			}
		
		wait(for: [expect], timeout: 30)
	}
	
	
	func testDecodeAndSinkUserSubscriberSucceed() {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: "MOCK_DATA_10", withExtension: "json")!
		
		let request = URLRequest(url: url)
		
		usersSubscriber = URLSessionTaskOperation.data(for: request)
			.publisher(on: queue)
			.map { data, response -> Data in
				return data
			}
			.decode(type: [CorrectUserModel].self, decoder: JSONDecoder())
			.eraseToAnyPublisher()
			.sink { (completion) in
				switch completion {
				case .finished:
					break
				case .failure(let error):
					XCTAssert(false, "\(error)")
				}
			} receiveValue: { (users) in
				expect.fulfill()
			}
		
		wait(for: [expect], timeout: 30)
	}
	
	func testDecodeAndSinkUserSubscriberFailure() {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: "MOCK_DATA_10", withExtension: "json")!
		
		let request = URLRequest(url: url)
		
		usersSubscriber = URLSessionTaskOperation.data(for: request)
			.publisher(on: queue)
			.map { data, response -> Data in
				return data
			}
			.decode(type: [WrongUserModel].self, decoder: JSONDecoder())
			.eraseToAnyPublisher()
			.sink { (completion) in
				switch completion {
				case .finished:
					XCTAssert(false, "Should not be succeed")
				case .failure:
					expect.fulfill()
				}
			} receiveValue: { (users) in
				XCTAssert(false, "Should not be Called because of failure")
			}
		
		wait(for: [expect], timeout: 30)
	}
	
	func testOperationPublisherWithDeliverToSucceed() {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: "MOCK_DATA_10", withExtension: "json")!
		
		let request = URLRequest(url: url)
		
		usersSubscriber =
			URLSessionTaskOperation.data(for: request)
			.publisher(on: queue)
			.deliver(to: JsonDecodeOperation<[CorrectUserModel]>())
			.sink { (completion) in
				switch completion {
				case .finished:
					break
				case .failure(let error):
					XCTAssert(false, "\(error)")
				}
			} receiveValue: { (users) in
				expect.fulfill()
			}
		
		
		wait(for: [expect], timeout: 30)
	}
	
	func testOperationPublisherWithDeliverToFailure() {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		let url = URL(string: "https://WrongAddress.com")!
		
		let request = URLRequest(url: url)
		
		usersSubscriber =
			URLSessionTaskOperation.data(for: request)
			.publisher(on: queue)
			.deliver(to: JsonDecodeOperation<[CorrectUserModel]>())
			.sink { (completion) in
				switch completion {
				case .finished:
					XCTAssert(false, "Should not be succeed")
				case .failure:
					expect.fulfill()
				}
			} receiveValue: { (users) in
				XCTAssert(false, "Should not be called on Failure")
			}
		
		
		wait(for: [expect], timeout: 30)
	}
	
	
	func testURLSessionDataTaskPublisherWithDeliverToSucceed() {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		expect.expectedFulfillmentCount = 2
		
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: "MOCK_DATA_10", withExtension: "json")!
		
		let request = URLRequest(url: url)
		
		usersSubscriber =
			URLSession.shared.dataTaskPublisher(for: request)
			.deliver(to: JsonDecodeOperation<[CorrectUserModel]>(), on: queue)
			.eraseToAnyPublisher()
			.sink { (completion) in
				switch completion {
				case .finished:
					expect.fulfill()

				case .failure(let error):
					XCTAssert(false, "\(error)")
				}
			} receiveValue: { (users) in
				expect.fulfill()
			}
		
		wait(for: [expect], timeout: 30)
	}
	
	func testURLSessionDataTaskPublisherWithDeliverToFailure() {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		let url = URL(string: "https://WrongAddress.com")!
		
		let request = URLRequest(url: url)
		
		usersSubscriber =
			URLSession.shared.dataTaskPublisher(for: request)
			.deliver(to: JsonDecodeOperation<[CorrectUserModel]>(), on: queue)
			.eraseToAnyPublisher()
			.sink { (completion) in
				switch completion {
				case .finished:
					XCTAssert(false, "Should not be succeed")
				case .failure:
					expect.fulfill()
				}
			} receiveValue: { (users) in
				XCTAssert(false, "Should not be called on Failure")
			}
		
		wait(for: [expect], timeout: 30)
	}
	
	func testOperationCombineWithoutRetry() {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		
		_opACounter = 0
		
		usersSubscriber =
			OperationA()
			.publisher(on: queue)
			.sink { (completion) in
				switch completion {
				case .finished:
					XCTAssert(false, "Should not be succeed")
				case .failure:
					expect.fulfill()
				}
			} receiveValue: { (users) in
				XCTAssert(false, "Should not be called on Failure")
			}
		
		wait(for: [expect], timeout: 30)
	}
	
	func testOperationCombineWithRetry() {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		
		_opACounter = 0
		
		usersSubscriber =
			OperationA()
			.publisher(on: queue)
			.retry(2)
			.sink { (completion) in
				switch completion {
				case .finished:
					break
				case .failure(let error):
					XCTAssert(false, "\(error)")
				}
			} receiveValue: { (users) in
				expect.fulfill()
			}
		
		wait(for: [expect], timeout: 30)
	}
	
	func testCancellingOperationPublisher() {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		
		_opACounter = 0
		
		usersSubscriber =
			OperationB()
			.didFinish({ (result) in
				if let error = result.error, error.publishedError is AOperationError.IsCancelled {
					expect.fulfill()
				}
				else {
					XCTAssert(false, "Should not be Succeed")
				}
			})
			.publisher(on: queue)
			.sink { (completion) in
				XCTAssert(false, "Should not be called because of cancel")
			} receiveValue: { (users) in
				XCTAssert(false, "Should not be called because of cancel")
			}
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
			self?.usersSubscriber?.cancel()
		}
		
		wait(for: [expect], timeout: 30)
	}
	
	func testChainedOperationPublishers() {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		
		usersSubscriber = OperationC1()
			.publisher(on: queue)
			.deliver(to: OperationC2())
			.deliver(to: OperationC3())
			.deliver(to: OperationC4())
			.sink { (_) in
				//...
			} receiveValue: { (result) in
				let finalNumber = result
				XCTAssert(finalNumber == 4)
				expect.fulfill()
			}

		wait(for: [expect], timeout: 30)
	}
	
	func testChainedOperationPublishersDecussate() {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		
		usersSubscriber = OperationC1()
			.publisher(on: queue)
			.map({ (received) -> Int in
				return received + 1
			})
			.deliver(to: OperationC2(), on: queue)
			.map({ (received) -> Int in
				return received + 1
			})
			.deliver(to: OperationC3(), on: queue)
			.map({ (received) -> Int in
				return received + 1
			})
			.deliver(to: OperationC4(), on: queue)
			.map({ (received) -> Int in
				return received + 1
			})
			.sink { (completion) in
				//...
			} receiveValue: { (result) in
				let finalNumber = result
				XCTAssert(finalNumber == 8)
				expect.fulfill()
			}

		wait(for: [expect], timeout: 30)
	}

	@Published var searchedText: String?
	
	func testMultipleTimeTextPublishesToCloneableMapOperationPublisherWithDeliverToSucceed() {
		_opACounter = 0
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		expect.expectedFulfillmentCount = 4
		
		usersSubscriber =
		$searchedText
			.compactMap({$0})
			.deliver(to: RetryableMapOperation<String>(), on: queue)
			.receive(on: RunLoop.main)
			.catch({_ in Just("Helllo")})
			.sink(receiveValue: { (value) in
				expect.fulfill()
				let count = opACount
				print("opACount is \(count)")
				print("value is \(value)")
				if count < 3 {
					self.searchedText = ["B", "Apple","C","Google", "Safari", "AOperation"][count]
				}

			})
				
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
			self.searchedText = "A"
		}
		
		
		wait(for: [expect], timeout: 30)
	}
	
	func testMultipleTimeTextPublishesToSimpleMapOperationPublisherWithDeliverToSucceed() {
		_opACounter = 0
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		
		usersSubscriber =
		$searchedText
			.compactMap({$0})
			.deliver(to: SimpleMapOperation<String>(), on: queue)
			.receive(on: RunLoop.main)
			.catch({_ in Just("Helllo")})
			.sink(receiveValue: { (value) in
				expect.fulfill()
				let count = opACount
				print("opACount is \(count)")
				print("value is \(value)")
				if count < 3 {
					self.searchedText = ["B", "Apple","C","Google", "Safari", "AOperation"][count]
				}

			})
				
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
			self.searchedText = "A"
		}
		
		
		wait(for: [expect], timeout: 30)
	}
	
	func testMultipleTimeTextPublishesToOperationPublisherWithDeliverToSucceed() {
		_opACounter = 0
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		expect.expectedFulfillmentCount = 4
		
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: "MOCK_DATA_10", withExtension: "json")!

		
		usersSubscriber =
		$searchedText
			.compactMap({$0})
			.filter({!$0.isEmpty})
			.debounce(for: 1, scheduler: RunLoop.main)
			.removeDuplicates()
			.deliver(to: FetchMockDataOperation(url: url), on: queue)
			.deliver(to: JsonDecodeOperation<[CorrectUserModel]>())
			.receive(on: RunLoop.main)
			.sink { (completion) in
				switch completion {
				case .finished:
					break
					//...
				case .failure(let error):
					XCTAssert(false, "\(error)")
				}
			} receiveValue: { (users) in
				expect.fulfill()
				let count = opACount
				print("opACount is \(count)")
				if count < 3 {
					self.searchedText = ["B", "Apple","C","Google", "Safari", "AOperation"][count]
				}
			}
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
			self.searchedText = "A"
		}
		
		
		wait(for: [expect], timeout: 30)
	}
	
	
}

fileprivate class SimpleMapOperation<Output>: ResultableOperation<Output>, ReceiverOperation {
	
	var receivedValue: Result<Output, AOperationError>?
	
	override func execute() {
		let value = self.receivedValue
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
			self.finish(with: value!)
		}
	}
}

fileprivate class RetryableMapOperation<Output>: ResultableOperation<Output>, ReceiverOperation, RetryableOperation {
	
	var receivedValue: Result<Output, AOperationError>?
	
	func new() -> Self {
		RetryableMapOperation<Output>() as! Self
	}
	
	override func execute() {
		let value = self.receivedValue
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
			self.finish(with: value!)
		}
	}
	
}

fileprivate struct CorrectUserModel: Decodable {
	var id: Int
	var firstName: String
	var lastName: String
	var fullName: String {
		return firstName + " " + lastName
	}
}

fileprivate struct WrongUserModel: Decodable {
	var id: Int
	var title: String
	var name: String
}

fileprivate class FetchMockDataOperation: WrapperOperation<String, (data: Data, response: URLResponse)>, RetryableOperation {
	
	func new() -> Self {
		FetchMockDataOperation(url: url) as! Self
	}
	
	let url: URL
	
	init(url: URL) {
		self.url = url
		super.init { (received) -> ResultableOperation<(data: Data, response: URLResponse)>? in
			print("received text is \((try? received?.get()) ?? "")")
			return URLSessionTaskOperation.data(for: url)
		}
	}
}


fileprivate class JsonDecodeOperation<Output: Decodable>: ResultableOperation<Output>, ReceiverOperation, RetryableOperation {
	
	
	var receivedValue: Result<(data: Data, response: URLResponse), AOperationError>?
	
	func new() -> Self {
		let new = JsonDecodeOperation<Output>()
		return new as! Self
	}

	
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
	
	struct Error: LocalizedError {
		public var errorDescription: String? {
			"Fetch User Failed"
		}
	}
	
}

fileprivate var _opACounter: Int = 0

fileprivate var opACount: Int {
	get {
		let count = _opACounter
		_opACounter += 1
		return count
	}
}

fileprivate class OperationA: WrapperOperation<Void, (data: Data, response: URLResponse)>, RetryableOperation {
	
	func new() -> Self {
		OperationA() as! Self
	}
	
	
	init() {
		super.init { (receivedValue) -> ResultableOperation<(data: Data, response: URLResponse)>? in
			
			
			let url: URL
			if _opACounter > 1 {
				url = URL(string: "https://jsonplaceholder.typicode.com/users/1")!
			}
			else {
				url = URL(string: "https://WrongAddress.com")!
				_opACounter += 1
			}
			
			
			
			return URLSessionTaskOperation.data(for: URLRequest(url: url))
		}
	}
}

fileprivate class OperationB: ResultableOperation<Data> {
	
	
	override func execute() {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 30) {
			self.finish(with: .success(Data()))
		}
	}
	
}

struct OperationCError: LocalizedError {
	var errorDescription: String? {
		return "OperationC Error"
	}
}


fileprivate class OperationC1: ResultableOperation<Int> {
	
	let initialNumber = 0
	
	override func execute() {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
			self.finish(with: .success(self.initialNumber + 1))
		}
	}
	
}


fileprivate class OperationC2: ResultableOperation<Int>, ReceiverOperation {
	
	var receivedValue: Result<Int, AOperationError>?
	
	
	override func execute() {
		guard let value = self.receivedValue else {
			self.finish(with: .failure(.receivedValueIsNil(in: self)))
			return
		}
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [self] in
			switch value {
			case .success(let initialNumber):
				self.finish(with: .success(initialNumber + 1))
			case .failure:
				self.finish(with: .failure(AOperationError(OperationCError())))
			}
		}
	}
	
}

fileprivate class OperationC3: ResultableOperation<Int>, ReceiverOperation {
	
	var receivedValue: Result<Int, AOperationError>?
	
	override func execute() {
		guard let value = self.receivedValue else {
			self.finish(with: .failure(.receivedValueIsNil(in: self)))
			return
		}

		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [self] in
			switch value {
			case .success(let initialNumber):
				self.finish(with: .success(initialNumber + 1))
			case .failure:
				self.finish(with: .failure(AOperationError(OperationCError())))
			}
		}
	}
	
}

fileprivate class OperationC4: ResultableOperation<Int>, ReceiverOperation {
	
	var receivedValue: Result<Int, AOperationError>?
	
	override func execute() {
		guard let value = self.receivedValue else {
			self.finish(with: .failure(.receivedValueIsNil(in: self)))
			return
		}

		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [self] in
			switch value {
			case .success(let initialNumber):
				self.finish(with: .success(initialNumber + 1))
			case .failure:
				self.finish(with: .failure(AOperationError(OperationCError())))
			}
		}
	}
	
}
