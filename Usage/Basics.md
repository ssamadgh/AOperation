# Basics

* **[AOPeration](#aoperation)**
	* [VoidOperation](#voidoperation)
	* [ResultableOperation](#resultableoperation)
	* [GroupOperation](#groupoperation)
	* [OrderedGroupOperation](#orderedgroupoperation)
	* [WrapperOperation](#wrapperoperation)
	* [AOperationDelegate](#aoperationdelegate)
* **[AOperationQueue](#aoperationQueue)**
* **[AOperationCondition](#aoperationcondition)**
* **[AOperationObserver](#aoperationobserver)**
* **[AOperationError](#aoperationerror)**
* **[AOperationDebugger](#aoperationdebugger)**

## AOPeration
This is the most basic type of AOperatons.
AOperation is a subclass of **[Operation](https://developer.apple.com/documentation/foundation/operation)** that added some features like conditions, observers, declarative Api, ... to it.
Because the AOperation class is an abstract class, you do not use it directly but instead subclass or use one of the pre-defined subclasses (**[DelayOperation](./Ready-to-use-operations.md#delayoperation)** or **[AOperationBlock](./Ready-to-use-operations.md#aoperationblock)**) to perform the actual task. Despite being abstract, the base implementation of Operation does include significant logic to coordinate the safe execution of your task. The presence of this built-in logic allows you to focus on the actual implementation of your task, rather than on the glue code needed to ensure it works correctly with other system objects.

## Subclassing AOperation
For subclassing you should not subclass AOperation directly. Instead use one of its two subclasses **VoidOperation** or **ResultableOperation**.

### VoidOperation
Use `VoidOperation` if you don't expect any result of your task and you just want it be done.
For using `VoidOperation` as subclass, create a class that inherited from `VoidOperation` and override `execute()` method. Do your tasks inside this method.
You should remember to call `finish()`, to notify operation your task is done and finish operation.
If your task published an error, pass an **[AOperationError](#aoperationerror)** type error to operation by using `finish(with: error)`.

```swift

class MyVoidOperation: VoidOperation {

	//1 You should override execute method
		override func execute() {
		//2 do your task
		//...
		
		if taskIsDoneSuccessful {
		//3 If it succeed finishing operation
		self.finish()
		}
		else
		//4 Or if it failed, finish operation with an error
		self.finish(with: error)
		}
	}


}
```
You can observe finishing of your operation as below:

```swift
let operation = MyVoidOperation()
operation.didFinish { result in
	if let error = result.error {
		// Handle error
	}
	else {
	//do your tasks
	}

}
```
This method called after operation moves to finished state.

If you want to do something before operation moves to finished state use `willFinish` state.

```swift
operation.willFinish { (result, finish)  in
	finish()
}
```
Note that you should call `finish()` at the end of closure to move operation to finished state othewise operation stays unfinished and doesn't exits from queue.

### ResultableOperation
Use `ResultableOperation<Output>` if you expect some resutl from your operation. The `Output` is type of output you expect from your task when its done.
For using `ResultableOperation` as subclass, create a class that inherited from `ResultableOperation<Output>` and override `execute` method. Do your tasks inside this method.
You should remember to call `finish(with:)`, with the received result from your task to notify operation your task is done and finishing operation.
The finish method accepts a `Result` parameter. Give it a `.success(value)` if your task succeed or a `.failure(error)` if your task failed. The error should be type of **[AOperationError](#aoperationerror)**.

```swift

class MyOperation: ResultableOperation<Data> {

	//1 You should override execute method
		override func execute() {
		//2 do your task
		
		someTask { taskOutput, error
		if let taskError = error {
		//3 Finish operation with error if task produced an error
		let operationError = AOperationError(taskError)
		self.finish(with: .failure(operationError))
		}
		else {
		self.finish(with: .success(taskOutput))
		}
		
		}
		
		
		
	}


}
```
You can observe finishing of your operation as below:

```swift
let operation = MyOperation()
operation.didFinish { result in

	switch result {
		case .success(let data):
		// do your task here
		
		case .failure(let error):
		// handle error here
		
	}

}
```
This method called after operation moves to finished state.

If you want to do something before operation moves to finished state use `willFinish` state.

```swift
operation.willFinish { (result, finish)  in
	finish()
}
```
Note that you should call `finish()` at the end of closure to move operation to finished state othewise operation stays unfinished and doesn't exits from queue.


### GroupOperation
A Group Operation is an Operation that takes several operations as input. The Group Operation finishes only if all the given operations finish their execution.

**Note:** Group operation doesn't guarantees which operation start first but it guarantees to finish only if all operation got finish.

```swift
let groupOperation = GroupOperation(operationA, operationB, operationC)
groupOperation.didFinish { (errors) in
			//...
			here is where all of the operationA, operationB and operationC are finished
		}
```
Also you can subclass `GroupOperation` to have a reusable operation.

```swift
class MyOperatoin: GroupOperation {

	init() {
		let operationA = OperationA()
		let operationB = OperationB()
		let operationC = OperationC()
		super.init([operationA, operationB, operationC])
	}
}
```

### OrderedGroupOperation

Ordered Group Operation is like a group operation whith the difference that the given operations execute in order. It means the first operation starts first and finishes first and last operation starts last and finishes last. OrderedGroupOperation finishes only if all the given operations get finish.


```swift
let groupOperation = OrderedGroupOperation(operationA, operationB, operationC)
groupOperation.didFinish { (errors) in
			//...
			here is where all of the operationA, operationB and operationC are finished
		}
```
Also you can subclass `OrderedGroupOperation ` to have a reusable operation.

```swift
class MyOperatoin: OrderedGroupOperation {

	init() {
		let operationA = OperationA()
		let operationB = OperationB()
		let operationC = OperationC()
		super.init([operationA, operationB, operationC])
	}
}
```
In above examples operations execute in order, means operationA starts first and finishes first
and operationC starts last and finishes last.

### WrapperOperation
An Operation that wraps another operation.
Consider an operation that you give it a URLRequest to 
do a task:

```swift
let url = URL(string: "A url string")!
var request = URLRequest(url: url)
request.allHTTPHeaderFields = 
["Authorization" : "An authorization code"]
let operation = URLSessionTaskOperation.data(for: request)
```
Using `WrapperOperation` you can wrap all of this lines of code and make a reusable operation:

```swift
let operation = WrapperOperation<Void, (response: URLResponse, data: Data)> { _ -> ResultableOperation<(response: URLResponse, data: Data)> in
	let url = URL(string: "A url string")!
	var request = URLRequest(url: url)
	request.allHTTPHeaderFields = 
	["Authorization" : "An authorization code"]
	return URLSessionTaskOperation.data(for: request)
}
```
Another way to create a `WrapperOperation` is subclassing it:

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

### AOperationDelegate
A protocol with methods for react to the changes of operation's lifecycle. Methods of this protocol notify when an operation starts to executtion and when an operation finishes its execution. To use this delegate, set the `delegate` property of operation equal to an object that conformed This Delegate.

```swift
class OperationDelegateManager: AOperationDelegate {

	func operationDidStart(_ operation: AOperation) {
	}
	
	func operationDidFinish(_ operation: AOperation, with errors: [AOperationError]) {
	}

}

let operation = MyOperation()
operation.delegate = OperationDelegateManager()
```
Note that all them methods of this delegate are optional.

## AOperationQueue

A subclass of **[OperationQueue](https://developer.apple.com/documentation/foundation/operationqueue)** that implements a large
 number of "extra features" related to the `AOperation` class like:
 
 * Notifying a delegate of all operation completion
 * Extracting generated dependencies from operation conditions
 * Setting up dependencies to enforce mutual exclusivity

To use an `AOperationQueue` define an instance with type of AOperationQueue:

```Swfit
	let queue = AOperationQueue()

```

Then add an `Operation` to it.

```Swfit
	let operation = SampleOperation()
	queue.addOperation(operation)
```
Another way of adding an operation to AoperationQueue is like below:

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



## AOperationCondition

 A protocol for defining conditions that must be satisfied for an
 operation to begin execution.

you create a condition by adopting `AOperationCondition` to a struct. By adding the condition to an operation. the satisfaction of operation will be check before operation start to execute.

`AOperationCondition` protocol has two required element needs to be conform.`dependentOperation` and `isMutuallyExclusive`.
`dependentOperation ` is the operation that doing tasks need to candition be satisfied. This operation added to the main operation as dependency and will be starts before main operation. By default if dependency operation fails the condition fails and the main operation will not execute.
By setting `isMutuallyExclusive` true, it prevents other condtions with the same type and their dependency operations execute and be check concurrently.
There are two other methods that have default implementions.

First `func dependencyForOperation(_ operation: AOperation) -> AOperation?` that returns `dependentOperation` by default, but by overriding this method you can handle it in your costum way.

Second `func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void)` that checks satisfaction of condition. This method by default checks if dependency operation has any published errors fails the given completion of method otherwise satisfies it. By overriding you can customize stisfaction of condition manually.

```swift
struct UserAccessConditoin: AOperationCondition {

	static var isMutuallyExclusive: Bool = false
	
	let dependentOperation: AOperation? = nil
	
	func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
	if User.current.hasAccess {
		completion(.success)
	}
	else {
	let error = AOperationError(AccessError.accessDenied)
	completion(.failure(error))
	}
	}
}
```
in above example, we check user access manually.
Another way of creating a `UserAccessConditoin` is like below:

```swift
struct UserAccessConditoin: AOperationCondition {
	static var isMutuallyExclusive: Bool = true
	
	let dependentOperation: AOperation? = RequestUserAccessOperation()
}
```
In above example`RequestUserAccessOperation` will be added as dependency to main operation, and executes first. `RequestUserAccessOperation` requests authorization for user to edit contents. If the operation fails the condition be fail. So the operation that this conditon added to it, will not be execute. 
By setting `isMutuallyExclusive` true, we make sure never two `RequestUserAccessOperation` executed concurrently.

Adding a condition to an operation is like below:

```swift
let operation = LikeCommentOperation(for: comment)
operation.conditions(UserAccessConditoin())
operation.didFinish { result in

	switch result {
	case .success:
		//update UI
	case .failure(let error):
		// You should handle received error
		//The failed error may be cause of UserAccessConditoin or LikeCommentOperation
	}
}
```
## AOperationObserver
The protocol that types may conform if they wish to be notified of significant
 operation lifecycle events.

This protocol notifies on operation starting to execution and finish of, also on produce a new operation.

A concerate example of  AOperationObserver is `TimeoutObserver` and `BlockObserver`.
AOperation `didStart(_:)` and `didFinish(_:)` methods are work based on `BlockObserver`.

## AOperationError
This is type of error used in AOperation. If your task failed and faced with error you finish the operation by passing an AOperationError created with the given error:

```swift
let error = AOperationError(receivedError)
self.finish(error)
```

Each `AOperationError` contains some information:

 * **state**:  Announces the state error published that wether is on condition satisfy checking (.condition) or operation execution (.execution)
 * **publisher**: Name of error publisher. By default is the type of condition or operation, published error.
 * **publishedError**: the published error by the failur task that passed to AOperationError. 

 Note that the `localizedDescription` property on AOperationError directly returns `localizedDescription` of publishedError.

 There are two predefined Error which you may encounter them.
 
 ### IsCancelled
 An error publishes when operation being cancel.
 
 ### ReceivedValueIsNil
 An error you can publish when `receivedValue` of a **ReceiverOperation** is nil.

## AOperationDebugger
A tool for tracking operations lifecycle.
You can simply debug and track any AOperation by using below code every where before running your operation:

```swift
AOperation.Debugger.printOperationsState = true
```

This line of code prints states of executed operation in debugger like below:

```
AOperation MyOperation added to queue
AOperation MyOperation executed
AOperation MyOperation cancelled
AOperation MyOperation finished
```
This way you can track any AOperation from start to finish. This is useful when you see one of your Operations remained unfinished and you wonder which one is.
Also sometimes AOperationDebugger gives you hints about why your operation not executed. For example you see this line if you forgot override `execute()` method:

```
AOperation MyOperation must override `execute()`.
```

Or you see this error if your operation conforms to **UniqueOperation** :

```swift
AOperation MyOperation ignored because of uniqueId (operation uniqueId)
```

## See Also

### [Declarative Programming with AOperation](./Declarative-operation.md)

### [Deliver result to another operation](./Deliver-to-operation.md)

### [Using AOperation with Combine](./AOperation-with-Combine.md)

### [Retrying an operation if it fails](./Retrying-an-operation-if-it-fails.md)

### [Some ready operations to use in your project](./Ready-to-use-operations.md)

### [Some ready conditions to use in your project](./Ready-to-use-conditions.md)

### [Some ready observers to use in your project](./Ready-to-use-observers.md)
