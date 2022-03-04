# Retrying an operation if it fails

An AOperation can be retryable if you adopt `RetryableOperation` protocol to it. This protocol has one method that is required to conform. `func new() -> Self` which you should retrun a new object of conformed operation in its implementation.

Consider this operation:

```swift
class FetchUserInfoOperation: ResultableOperation<UserInfo> {

	override public func execute() {
	// Som task is done here
	}

}
```
By adopting `RetryableOperation` to this operation we make it retryable.

```swift
class FetchUserInfoOperation: ResultableOperation<UserInfo>, RetryableOperation {

	public func new() -> Self {
		FetchUserInfoOperation() as! Self
	}


	override public func execute() {
	// Som task is done here
	}

}
```

Use this feature in operation execution like below.

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
 
 By calling `retryOnFailure(_:)`  method on operation you can manage when it should be retry. This method has a closure with three parameter. A `numberOfRetries` which shows how many time you retried since now. At the first time operation fails the value of this parameter is `0`, which means the operation doesn't retry yet. An `error` which is error of operation failure. A `retry` method that should be called at the end of closure and has an boolean input which tells to the operation wether it should execute again (`true`) or completely finished(`false`). 

In another example we could manage `retryOnFailure` closure like below.

```swift
FetchUserInfoOperation()
.retryOnFailure({(numberOfRetries, error, retry) in
	if (error.publishedError as? URLError).errorCode == URLError.Code.timedOut {
		retry(true)
	}
	else {
		retry(false)
	}
}
.didFinish { result
//Update UI
}
.add(to: queue)
```

Note that `didFinish(_:)` doesn't call if you set ` retry(_:)` input as `true`.
