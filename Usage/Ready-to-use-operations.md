# Some ready operations to use in your project 
There are some ready to use operations in AOperation framework which we will review them below 

* **[AOperationBlock](#aoperationblock)**
* **[DelayOperation](#delayoperation)**
* **[RemainedDelayOperation](#remaineddelayoperation)**
* **[URLSessionTaskOperation](#urlsessiontaskoperation)**
	* **[URLSessionDataTaskOperation](#urlsessiondatataskoperation)**
	* **[URLSessionDownloadTaskOperation](#urlsessiondownloadtaskoperation)**
	* **[URLSessionUploadTaskOperation](#urlsessionuploadtaskoperation)**
* **[AlertOperation](#alertoperation)**

## AOperationBlock
A subcalss of **[VoidOperation](./Basics.md#voidoperation)** that executes a closure.
You can use AOperationBlock closure in two way.
1. On main thread. This way the closure executes on main thread. This is useful if you want set a condition on a code that should execute on main thread like presenting a viewController.

```swift
AOperationBlock {
	self.present(viewController, animated: true, completion: nil)
}
.add(to: queue)
```
2. On OperationQueue thread. This way you should handle finishing of block operation manually.

```swift 
AOperationBlock { finish in
	// do your task
	finish()
}
.add(to: queue)
```

## MapOperationBlock
A subclass of **[ResultableOperation](./Basics.md#resultableoperation)** that executes a closure.
Use this operation if you want to change type of upstream operation result to a new type.

```swift
URLSessionTaskOperation.data(for: url)
.deliver(to: MapOperationBlock<(data: Data, response: URLResponse), UIImage> { receivedValue, finish in

	do {
		if let data = try receivedValue?.get().data,
		   let image = UIImage(data: data)
		{
			finish(.success(image))
		}
		else {
			finish(.failure(.receivedValueIsNil(in: self)))
		}
	}
	catch {
		finish(.failure(error as! AOperationError))
	}
	
})
.add(to: queue)
```

## DelayOperation
A subclass of **[ResultableOperation](./Basics.md#resultableoperation)** that will simply wait for a given time
    interval, or until a specific `Date`.

Use this operation to make delay on execution of an operation:

```swift
DelayOperation<Void>(1)
.deliver(to: FetchUserInfoOperation())
.didFinish { result in
// update UI
}
.add(to: queue)
```
You can also use this operation to make delay in the middle of a chain of operations:

```swift
URLessionTaskOperation.data(for: url)
.deliver(to: DelayOperation<(data: Data, response: URLResponse)>(0.5))
.didFinish { result
	//update UI
}
```

Another place you can use this operation is in **[OrderedGroupOperation](./Basics.md#orderedgroupoperation)**:

```swift
OrderedGroupOperation(Operation1(), DelayOperation<Void>(2), Operation2())
.add(to: queue)
```
## RemainedDelayOperation
A subclass of **[ResultableOperation](./Basics.md#resultableoperation)**  that will simply wait for a remained time from a given time interval.
When **RemainedDelayOperation** initializes, it records absolute time of initiailize and when the operation  starts to execute it calcualtes current absolute time difference to the initialize absolut time
	and it waits for remained time from the given time or finishes if remained time is less than or equal to 0.
For example Consider below chain of operations:

```swift
OrderedGroupOperation(OperationA(), RemainedDelayOperation <Void>(5), OperationB())
.add(to: queue)
```
Suppose it takes two seconds for the operationA to complete. Now its time to RemainedDelayOperation to execute. Because of the difference between initialize and execution of RemainedDelayOperation is 2 second so only three seconds remain from the given time interval to the RemainedDelayOperation (5 second). So delay time would be 3 second and after 3 seconds OperationB will be execute.
The usage of this operation is similiar to DelayOperation.

## URLSessionTaskOperation
Provides some static methods for accessing operations that handle  URLSession related tasks like download and upload.

### URLSessionDataTaskOperation 
An operatoin that handles URLSessionDataTask request and result. 
You can use this operation as shown below:

```swift
URLSessionTaskOperation.data(for: url)
.didFinish { result in
}
.add(to: queue)
``` 
The result `output` type of this operation is `(data: Data, response: URLResponse)`.


### URLSessionDownloadTaskOperation
An operatoin that handles URLSessionDownloadTask request and result. 
You can use this operation as shown below:

```swift
URLSessionTaskOperation.download(for: url)
.didFinish { result in
}
.add(to: queue)
``` 
The result `output` type of this operation is `(url: URL, response: URLResponse)`.

### URLSessionUploadTaskOperation
An operatoin that handles URLSessionUploadTask request and result. 
You can use this operation as shown below:

```swift
URLSessionTaskOperation.upload(for: url)
.didFinish { result in
}
.add(to: queue)
``` 
The result `output` type of this operation is `(data: Data, response: URLResponse)`.

## AlertOperation
An Operation that presents a UIAlertController on top view controller of app or the given view controller.
A simple example of using this opration is shown below:

```swift
		let alert = AlertOperation()
			alert.title = "Unable to Download"
			alert.message = "Cannot download requested data. try again later."
			alert.add(to: queue)
```

