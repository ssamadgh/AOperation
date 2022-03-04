# CheatSheet
Use this cheatsheet for a fast review and training of **AOperation** features

## [AOperation](./Basics.md#aoperation)
 subclass of **[Operation](https://developer.apple.com/documentation/foundation/operation)** that added some features like conditions, observers, declarative Api, ... to it.

## [VoidOperation](./Basics.md#voidoperation)
Use `VoidOperation` if you don't expect any result of your task and you just want it be done.

```swift
class MyVoidOperation: VoidOperation {
	override public func execute() {
		
		do {
			try doSomething()
			finish()
		}
		catch {
			finish(with: AOperationError(error))
		}
		
	}

}
```
## [ResultableOperation](./Basics.md#resultableoperation)
Use `ResultableOperation<Output>` if you expect some resutl from your operation.

```swift
class MyVoidOperation: VoidOperation {
	override public func execute() {
		
		do {
			let result = try doSomething()
			finish(with: .success(result))
		}
		catch {
			finish(with: .failure(AOperationError(error)))
		}
		
	}

}
```

## [GroupOperation](./Basics.md#groupoperation)
A Group Operation is an Operation that takes several operations as input and finishes only if all the given operations finish their execution.

```swift
let groupOperation = GroupOperation(operationA, operationB, operationC)
```

## [OrderedGroupOperation](./Basics.md#orderedgroupoperation)
Ordered Group Operation is like a group operation whith the difference that the given operations execute in order.

```swift
let groupOperation = OrderedGroupOperation(operationA, operationB, operationC)
```

## [WrapperOperation](./Basics.md#wrapperoperation)
An Operation that wraps another operation.

```swift
class AuthorizedOperation: WrapperOperation<Void, (response: URLResponse, data: Data)> {
	
	init() {
		super.init { _ -> ResultableOperation<(response: URLResponse, data: Data)> in
			let url = URL(string: "A url string")!
			var request = URLRequest(url: url)
			request.allHTTPHeaderFields = 
			["Authorization" : "An authorization code"]
			return URLSessionTaskOperation.data(for: request)

		}
	}

}
```

You can also use WrapperOperation to wrap a chain of operations:

```swift
class ServiceOperation<Output: Decodable>: WrapperOperation<Void, Output> {
	init(url: URL) {
		super.init { (_) -> ResultableOperation<Output>? in
			return
			URlSessionTaskOperation.data(for: url)
			.deliver(to: ServicesErrorHandleOperation())
			.deliver(to: JSONDecoderOperation<Output>())
		}
	}
}
```

## [AOperationDelegate](./Basics.md#aoperationdelegate)

A protocol with methods for react to the changes of operation's lifecycle.

```swift
class SampleOperation: VoidOperation, AOperationDelegate {

	override public func execute() {
		// do some task
	}


	func operationDidStart(_ operation: AOperation) {
	}
	
	func operationDidFinish(_ operation: AOperation, with errors: [AOperationError]) {
	}

}

```

## [ReceiverOperation](./Deliver-to-operation.md)

A protocol that declares an AOperation type that can receive input from a ResultableOperation or OperationPublisher.

**Implementation**

```swift
class ErrorHandleOperation: ResultableOperation<Data>, ReceiverOperation {

	public var receivedValue: Result<(data: Data, response: URLResponse), AOperationError>?
	
	public override func execute() {
		// do some task
	}

}

```
**Usage**

```swift
let url = URL(string: "https://ServerHost.com/userInfo")
URlSessionTaskOperation.data(for: url)
.deliver(to: ErrorHandleOperation())
.didFinish { result in

}
```

## [RetryableOperation](./Retrying-an-operation-if-it-fails.md)

A protocol that operations conform to support attempts to recreate a finished operation.

**Implementation**

```swift
class FetchUserInfoOperation: VoidOperation, RetryableOperation {

	func new() -> Self {
		SampleOperation() as! Self
	}
	
	public override func execute() {
		// do some task
	}

	
}
```

**Usage**

This protocl should be conformed if you want to use `retryOnFailure` method.

```swift
FetchUserInfoOperation()
.retryOnFailure({(numberOfRetries, error, retry) in
	retry(true)
}
.didFinish { result
//Update UI
}
.add(to: queue)
```

Or receive a sequence of values over time from a Combine upstream publishers.

```swift
subscriber =
		$searchedText
			.compactMap({$0})
			.deliver(to: SimpleMapOperation<String>(), on: queue)
			.retry(2)
			.receive(on: RunLoop.main)
			.catch({_ in Just("Helllo")})
			.sink(receiveValue: { (value) in

				//do something with received value
			
			})
```


## [UniqueOperation](./Making-an-AOperation-Unique.md)

A protocol that declares  an operation type that should be unique.
By adopting this protocol to an operation type you prevent that type from duplicate executation in same time.

```swift
class SampleOperation: VoidOperation, UniqueOperation {
	var uniqueId: String = "A Unique String"
}
```

## [AOperationQueue](./Basics.md#aoperationQueue)

A subclass of **[OperationQueue](https://developer.apple.com/documentation/foundation/operationqueue)** that implements a large  number of "extra features" related to the `AOperation` class.
 
```Swfit
	let queue = AOperationQueue()
		let operation = SampleOperation()
	queue.addOperation(operation)
```

Another way of adding operation to queue:

```swift
SampleOperation()
.add(to: queue)
```

### AOperationQueue.shared
A global instance of `AOperationQueue` that you can use it if you need.

```Swfit
	SampleOperation()
	.add(to: .shared)
```

## [Declarative programming with AOperation](./Declarative-operation.md)

AOperation supports declarative syntax.

```swift
URLSessionTaskOperation.data(for: url)
.conditions(UserAccessCondition())
.observers(TimeoutObserver(5))
.delvier(to: JsonDecoderOperation<[Comments]>)
.didFinish { result in
    // Update UI
}
.add(to: queue)
```

## [Using AOperation with Combine](./AOperation-with-Combine.md)

**AOperation** is fully compatible with **[Combine](https://developer.apple.com/documentation/combine)**.

```swift
cancellable =
	$searchedText
	.throttle(for: 2, scheduler: RunLoop.main, latest: true)
	.compactMap({ (text) -> String? in
		return text?.replacingOccurrences(of: " ", with: "")
	})
	.filter({!$0.isEmpty})
	.removeDuplicates()
	.deliver(to: ModernFetchUserTimeLineOperation(), on: queue)
	.catch({ _ in Just([])})
	.assign(to: \.tweets, on: self)
```

## [AOperationCondition](./Basics.md#aoperationcondition)
 A protocol for defining conditions that must be satisfied for an
 operation to begin execution.
 
```swift
struct UserAccessConditoin: AOperationCondition {
	static var isMutuallyExclusive: Bool = true
	
	let dependentOperation: AOperation? = RequestUserAccessOperation()
}
```

## [AOperationObserver](./Basics.md#aoperationobserver)
The protocol that types may conform if they wish to be notified of significant
 operation lifecycle events.
 
 ```swift
 SampleOperation()
 .didStart {
 }
 .didFinish { result in
 }
 .add(to: queue)
 ```
 
## [AOperationError](./Basics.md#aoperationerror)
The type of error used in AOperation.

```swift
let error = AOperationError(receivedError)
self.finish(error)
```
## [AOperationDebugger](./Basics.md#aoperationdebugger)
A flag that if you turn it on, prints some message on debugger about operations lifecycle.

```swift
AOperation.Debugger.printOperationsState = true
```

## See Also

### [Basics](./Basics.md)

### [Take the most advantage of conditions](./Advantage-of-conditions.md)


### [Some ready operations to use in your project](./Ready-to-use-operations.md)

### [Some ready conditions to use in your project](./Ready-to-use-conditions.md)

### [Some ready observers to use in your project](./Ready-to-use-observers.md)

