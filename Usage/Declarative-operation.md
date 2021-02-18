# Declarative Programming with AOperation 

one of the AOperation features is that
it supports declarative syntax.
Means that you can do all of an operation configs in a chain, without needs of repeatedly refer to the declared property of it.
Let see some example.
The old way of defining an operation is as below:

```swift
let operation = LikeACommentOperation(comment)
operation.addCondition(UserAccessCondition())
operation.didFinish { result in
	// Update UI
}

queue.addOperation(operation)
```
As you see using `AOperation` in this way is very tedios and time consuming.
But with the new declrative syntax you have this:

```swift
LikeACommentOperation(comment)
.conditions(UserAccessCondition())
.didFinish { result in
	// Update UI
}
.add(to: queue)
```
Very beautiful and neat!

The story does not end here. Using **[ReceiverOperation](./Deliver-to-operation.md)** protocol you can connect operations to each other like a chain. Each operation receives the result of its back operation:

```swift
URLSessionTaskOperation.data(for: url)
.delvier(to: JsonDecoderOperation<[Comments]>)
.didFinish { result in
	// Update UI
}
.add(to: queue)
```
You can add observers and dependencies this way too:

```swift
URLSessionTaskOperation.data(for: url)
.observers(TimeoutObserver(5))
.delvier(to: JsonDecoderOperation<[Comments]>)
.didFinish { result in
    // Update UI
}
.add(to: queue)
```
Using **[RetryableOperation](./Retrying-an-operation-if-it-fails.md)** protocol you can 
handle failure situations and retry the chain as number as you need:

```swift
URLSessionTaskOperation.data(for: url)
.delvier(to: JsonDecoderOperation<[Comments]>)
.retryOnFailure { (numberOrRetries, error, retry) in
	retry(numberOrRetries < 1)
}
.didFinish { result in
    // Update UI
}
.add(to: queue)
```
Note that you should always use `add(to:)` mehtod at the end of the chain.

The new declarative syntax of AOperation makes using it easy and enjoyable.
