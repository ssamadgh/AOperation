# Deliver result to another operation

In AOperation you can deliver result of an operation to another operation.
Using this feature, your operations will have the following privileges:

* **Single Responsible**
* **Reusable**
* **Small in Size**
* **Easy to understand**

To use this feature you should adopt `ReceiverOperation` to your operation.
Doing this the only thing you should conform is a `receivedValue` property. This property is type of `Result<Input, AOperationError>` which `Input` is a generic type.
The Generic `Input` type should be equal to the `Output` type of operation should deliver its result.
Let see how to use `ReceiverOperation`.
Imagine we have below operation

```swift
let url = URL(string: "https://ServerHost.com/userInfo")
URlSessionTaskOperation.data(for: url).didFinish { result in

}
```
The received result of above operation in `didFinish` closure gives a success type of `(response: URLResponse, data: Data)`.
This result is almost unusable in its current form.
Lets convert it to a usable form using `ReceiverOperation`.

First we should handle `URLResponse` value.
For this we create a new operation named `ServicesErrorHandleOperation` like below.


```swift
//1.
public class ServicesErrorHandleOperation: ResultableOperation<Data>, ReceiverOperation {
	
	enum Error: LocalizedError {
		case serverResponseError
	}
	
	//2.
	public var receivedValue: Result<(data: Data, response: URLResponse), AOperationError>?
	
	public override func execute() {
	//3.
		guard let value = receivedValue else {
	//4.
			finish(with: .failure(.receivedValueIsNil(in: self)))
			return
		}
		
		//5.
		switch value {
		case let .success((data, response)):
		//6.
			let response = (response as! HTTPURLResponse)
			let statusCode = response.statusCode
			if (statusCode >= 200 && statusCode <= 299) {
	
				finish(with: .success(data))
			}
			else {
	//7.
			let error = AOperationError(Error.serverResponseError)
			finish(with: .failure(error))
			}
		case .failure(let error):
	//8.
			finish(with: .failure(error))
		}
		
	}
	
}
```

In above operation:

1. We set `Output` type of operation `Data`. This is the type we want publish as result of this operation.
2. We defined `Input` type of receivedValue equal to the `Output` of `URLSessionDataTaskOperation` which is `(data: Data, response: URLResponse)`.
3. Check that the `receivedValue` is not nil.
4. if the received value is nil we publish  a framework ready-made error using `.receivedValueIsNil(in: self)`. This method returns an `AOperationError` with a published error of type `ReceivedValueIsNil`.
5. We check whether the `receivedValue` is success or failure.
6. If `receivedValue ` is success, we check status code of `receivedValue` response to be between 200 to 299 and publish `receivedValue` data as result of operation.
7. Otherwise we publish an `AOperationError` with published error `Error.serverResponseError`
8. If `receivedValue` is failure, we directly publish `receivedValue` error.

Now using `ServicesErrorHandleOperation` we write our initial code as follows:


```swift
let url = URL(string: "https://ServerHost.com/userInfo")
URlSessionTaskOperation.data(for: url)
.deliver(to: ServicesErrorHandleOperation())
.didFinish { result in

}
```

We get rid of response and now we only have a data as success type of result.
With a decoder operation like the example below we can convert data to desired model type:

```swift
public class JSONDecoderOperation<Output: Decodable>: ResultableOperation<Output>, ReceiverOperation {
	
	public var receivedValue: Result<Data, AOperationError>?

	
	public override func execute() {
		guard let value = receivedValue else {
			finish(with: .failure(.receivedValueIsNil(in: self)))
			return
		}
		
		switch value {
		case .success(let data):
			
			do {
				let decoded = try JSONDecoder().decode(Output.self, from: data)

				self.finish(with: .success(decoded))
			} catch {
				finish(with: .failure(AOperationError(error)))
			}

			
		case .failure(let error):
			finish(with: .failure(error))
		}
	}
	
}
```

In above Operation, `Input` type of receivedValue is `Data` and the `Output` is a generic type that conformed `Decodable`.

So finaly we could write our code like this:

```swift
let url = URL(string: "https://ServerHost.com/userInfo")
URlSessionTaskOperation.data(for: url)
.deliver(to: ServicesErrorHandleOperation())
.deliver(to: JSONDecoderOperation<User>())
.didFinish { result in
	switch result {
	case .success(let user):
	// Update UI
	case .failure(let error):
	// Handle error
	}
}
```
Now we have a result with our desired model as success type.
You see how each of operations are  **Single Responsible**, **Reusable**, **Small in Size** and **Easy to understand**. 
Our final bunch of codes also are clear and understandable.

# Using WrapperOperation to Make a Chain of Operations Encapsulated and Reusable
By use of **[WrapperOperation](./Basics.md#wrapperoperation)** we can make a chain of operations wrapped and reusable.
For example we can wrap up the above chain of operations like below

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
So the above codes are reduced to the following lines of codes:

```swift
let url = URL(string: "https://ServerHost.com/userInfo")
ServiceOperation<User>()
.didFinish { result in
	switch result {
	case .success(let user):
	// Update UI
	case .failure(let error):
	// Handle error
	}
}
```
We used `WrapperOperation` to wrap a chain of operations as a single operation, which gets the first operation of chain input parameter as input and results the last operation of chain output as output

As you see the most important thing about `ServiceOperation` is that its **encapsulated** and **reusable**.
