//
//  URLSessionTaskOperationTest.swift
//  AOperation_iOS_Tests
//
//  Created by Seyed Samad Gholamzadeh on 1/1/21.
//

import XCTest
import AOperation

class URLSessionTaskOperationTest: XCTestCase {
	
	let queue = AOperationQueue()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testURLSessionDataOperation() throws {
		let expect = expectation(description: "Test URLSessionTaskOperation.data operation")
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: "MOCK_DATA_10", withExtension: "json")!

		let request = URLRequest(url: url)

		URLSessionTaskOperation.data(for: request).didFinish { (result) in
			switch result {
			case let .success((data, _)):
				let jsonData = try! Data(contentsOf: url)
				XCTAssertEqual(data, jsonData)
				expect.fulfill()
			case .failure:
				XCTAssert(false, "Result should not be failure")
			}
		}
		.add(to: queue)
		wait(for: [expect], timeout: 10)
		
    }

	
}
