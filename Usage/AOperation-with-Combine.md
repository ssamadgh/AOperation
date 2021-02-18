# Using AOperation with Combine

* **[Why should use AOperation with Combine?](#why-should-use-aoperation-with-combine?)**
* **[How to use AOperation with Combine](#how-to-use-aoperation-with-combine)**


**AOperation** is fully compatible with **[Combine](https://developer.apple.com/documentation/combine)**, A framework that provides a declarative Swift API for processing values over time.

## Why should use AOperation with Combine?

Combine framework itself has a lot of functions and capabilities to manage tasks in projects.
So this question arises why should use AOperation with Combine or what is the advantage of AOperation to Combine's functions and tools?
The Answer is AOperation features like conditions, observers, ability to modulate and encapsulate codes, dependencies, operations chaining, easy usability and ..., provides some powers and abilities that is hard to achieve in combine. So using these two frameworks together you'll benefit from the power of both.

## How to use AOperation with Combine

Using AOperation with combine is realy simple.

### AOperation as Publisher

Publishers can deliver a sequence of values over time. To use an operation as a publisher, simply use `publisher(_:)` on it.

```swift
MyOperation()
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

```
### Receive elements from Upstream publisher
To be able receive elements from an upstream publisher, An AOperation class should conforms to **[ReceiverOperation](./Deliver-to-operation.md)** and **[RetryableOperation](./Retrying-an-operation-if-it-fails.md)**.
Then by calling `deliver(to:on:)` method on upstream publisher and pass your operation to it as input you can receive elements from upstream publisher.

Consider this operation:

```swift
fileprivate class SimpleMapOperation<Output>: ResultableOperation<Output>, ReceiverOperation {
	
	var receivedValue: Result<Output, AOperationError>?
	
	override func execute() {
		let value = self.receivedValue
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
			self.finish(with: value!)
		}
	}
}
```
We can use this operation as publisher as below:

```swift
subscriber =
		$searchedText
			.compactMap({$0})
			.deliver(to: SimpleMapOperation<String>(), on: queue)
			.receive(on: RunLoop.main)
			.catch({_ in Just("Helllo")})
			.sink(receiveValue: { (value) in

				//do something with received value
			
			})
```
