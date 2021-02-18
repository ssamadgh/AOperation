# Some ready observers to use in your project 

* **[BlockObserver](#blockobserver)**
	* [didStart](#didstart)
	* [didProduce](#didproduce)
	* [didFinish](#didfinish)
* **[TimeoutObserver](#timeoutobserver)**
* **[NetworkObserver](#networkobserver)**
* **[ReachabilityObserver](#reachabilityobserver)**

## BlockObserver
The **BlockObserver** is a way to attach arbitrary blocks to significant events
 in an **AOperation**'s lifecycle.
 
 ```swift
 let observer = 
 BlockObserver(startHandler: { operation in
			// do something on start
		},
		produceHandler: { operation, newOperation in
		// do something on produce operation
}, finishHandler: { operation, errors
	// do something on finishing operation
})
 ```
There are some helper methods that used **BlockObserver** which are easy to use for observing AOperation lifecycle:

### didStart
Call this method on operation to observe starting of operation.

```swift
operation
.didStart {
}
.add(to: queue)
```

### didProduce

Call this method on operation to observe produceing a newOperation.

```swift
operation
. didProduce { newOperation in
}
.add(to: queue)
```

### didFinish

Call this method on operation to observe finished of operation.

- **Note1**: This method is additive. means that all your called closures will be execute.
- **Note2**: This method is execute in **Main** thread. So you can call UI functions into the closure in safety.

```swift
operation
.didFinish { result in
}
.add(to: queue)
```

### willFinish
Call this method on operation to observe finishing of operation. this closure is executed just before operation moves to finished state. Use this method if you really need to your code execute before operation moves to finished, otherwise use `didFinish`.

- Note: This method will just execute the last called function. So consider this in use of this method.

```swift
operation
.willFinish { result, finish in
	// doing something
	finish
}
.add(to: queue)
```

## TimeoutObserver
**TimeoutObserver** is a way to make an Operation automatically time out and  cancel after a specified time interval.

```swift
operation
.observers(TimeoutObserver(5))
.add(to: queue)
```

## NetworkObserver

An `AOperationObserver` that will cause the network activity indicatior to appear as long
as the `AOperation` to which it is attached is executing.

```swift
operation
.observers(NetworkObserver())
.add(to: queue)
```

## ReachabilityObserver
An observer that performs a very high-level reachability observing.
Use this observer to react on reachablility change during the operation execution.

```swift
operation
.didChangeReachability { operation, connection
	//React to connection change
}
```
