# Making an AOperation Unique

`UniqueOperation` is a protocol that by adopting it to an AOperation, you prevent that type of operation from duplicate executation in same time. The only requirement that should conform for this protocol is a `uniqueId` property that helps AOperationQueue to track Operations with same `uniqueId`.
Let see how it works.
Consider below operation.

```swift
class MyOperation: VoidOperation {

override public func execute() {
}

}
```

we create two operation of type `MyOperation` and add it to queue.

```swift
let operation1 = MyOperation()
let operation2 = MyOperation()
queue.addOperation(operation1)
queue.addOperation(operation2)
```
If we do not limit maximum number of concurrent operations in queue, these two operations will execute concurrently and you don't know which one will execute first and which one will executes second.
By limiting maximum number of concurrent operations in queue to 1, these operations execute serialy, meaning that operation 1 executes first and operation2 execute second.
But there is some times,you want only one operation of a special type be added to queue and you do not have control on operations  added to the queue. 
For example Imagine you are used AOperation to show alerts to user if a failure error published from a server request. Its a common scenario that two server request error occured with a short distance of each other and therefore two alert operation added to queue. User sees alerts one after another which is not a good user exprience. Adopting `UniqueOperation` to AlertOperation solves this problem.

Consider this alert operation

```swift
classs AlertOperation: VoidOperation, UniqueOperation {

var uniqueId: String = "UniqueAlertOperation"

}

```

Lets add two alert operation to queue.

```swift
let operation1 = AlertOperation()
let operation2 = AlertOperation()
queue.addOperation(operation1)
queue.addOperation(operation2)
```

In above scenario, `operation1` added to queue, AOperationQueue detects its a `UniqueOperation` type so remembers its `uniqueId`. By adding `operation2` to queue, AOperationQueue realizes this is also a `UniqueOperation` type with the same `uniqueId` as the `operation1`, so AOpertionQueue ignores to add `operation2` to queue.

### How do we know a kind of operation ignored to add to queue because of same unique id?

By setting `AOperation.Debugger.printOperationsState` to `true`, AOperationQueue prints a message that announces operations ignored because of their `uniqueId`. For the above scenario this message would be like this:

**`AOperation AlertOperation ignored because of uniqueId UniqueAlertOperation`**
