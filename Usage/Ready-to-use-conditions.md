# Some ready conditions to use in your project 
There are some ready to use conditions in AOperation framework which we will review them below 

* **[MutuallyExclusive](#mutuallyexclusive)**
* **[NoCancelledDependencies](#nocancelleddependencies)**
* **[SilentCondition](#silentcondition)**
* **[NegatedCondition](#negatedcondition)**
* **[ReachabilityCondition](#reachabilitycondition)**
* **[MediaCaptureCondition](#mediacapturecondition)**
* **[LocationCondition](#locationcondition)**
* **[UNNotificationCondition](#unnotificationcondition)**
* **[UIImagePickerAvailabilityCondition](#uiimagepickeravailabilitycondition)**
* **[ConditionBlock](#conditionblock)**

## MutuallyExclusive
A generic condition for describing kinds of operations that may not execute concurrently.
This condition is coupled with AOperationQueue.
When you add this condition to operations and adding them an AOperationQueue. AOperationQueue checks this condition on operations and makes them dependent to each other in order they added to queue using the generic key you set on condition. 

```swift
struct MutuallyRequestAccessToken {
	
}

let condition = MutuallyExclusive<MutuallyRequestAccessToken>()
operation.addCondition(condition)
```

The operations you added them a mutuallyExclussive condition with the same generic key will execute serially, no matter where you added them to queue in project.

## NoCancelledDependencies
A condition that specifies that every dependency must have succeeded.
If any dependency was canceled, the target operation will be canceled as well.
    
```swift
let condition = NoCancelledDependencies()
operation.addCondition(condition)
```

## SilentCondition
A simple condition that causes another condition to not enqueue its dependency.
This is useful (for example) when you want to verify that you have access to the user's location, but you do not want to prompt them for permission if you do not already have it.

```swift
let locationCondition = LocationCondition(usage: .always, servicesAvailability: [.headingAvailable])
let condition = SilentCondition(locationCondition)
operation.addCondition(condition)
```

## NegatedCondition
A simple condition that negates the evaluation of another condition.
This is useful (for example) if you want to only execute an operation if the  network is NOT reachable.

```swift
let reachability = ReachabilityCondition()
let condition = NegatedCondition(reachability)
operation.addCondition(condition)
```
## ReachabilityCondition
This is a condition that performs a very high-level reachability check.
It provides a long-running reachability check, meaning that if current status of connection is different from desired connection status, condition can keep operation on pending till connection status changes.
There are some parameters this condition accepts as input.
**url**
The url which user wants to chack reachability to it The default value is nil
**connection**
The type of connection which user wants to have If the value of this parameter set to nil, the condition checks if connection is other than .none. The default value is nil
**waitToConnect**
set this parameter true, to keep operation on pending till connection status changes to expected status. By setting this parameter to false, reachability is evaluated once when the operation to which this is attached is asked about its readiness. The default value is false.

```swift
let reachability = ReachabilityCondition(connection: .wifi, waitToConnect: true)
operation.addCondition(reachability)
```

## MediaCaptureCondition
A condition for verifying and request access to media types available on device.

```swift
let condition = MediaCaptureCondition(mediaType: .audio)
operation.addCondition(condition)
```

## LocationCondition
A condition for verifying access to the user's location.

```swift
let condition = LocationCondition(usage: .whenInUse, servicesAvailability: [.headingAvailable])
operation.addCondition(condition)
```
## UNNotificationCondition
A condition for verifying that is it available to present alerts to the user via
    **[UNNotification](https://developer.apple.com/documentation/usernotifications/)** .

```swift
let condition = UNNotificationCondition(options: [.badge, .sound], servicesAvailability: [.headingAvailable])
operation.addCondition(condition)
```

## UIImagePickerAvailabilityCondition

A condition for verifying **[UIImagePicker](https://developer.apple.com/documentation/uikit/uiimagepickercontroller)** source and media types availability on device.

```swift
let condition = UIImagePickerAvailabilityCondition(sourceType: .camera, mediaTypes: [(kUTTypeMovie as String)])
operation.addCondition(condition)
```

## ConditionBlock
A closuer of conditon that should be checked before operation starts.

```swift
operation.condition { [weak self] completion in
	if self.user != nil {
		completion(.success)
	}
	else {
	let error = AOperationError(Error.userIsNotSigned)
		completion(.failure(error))
	}
}
```
