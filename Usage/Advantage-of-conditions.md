# Take the most advantage of conditions

Conditions are one of the most important features of AOperation framework.

Using them properly, you can turn a large and complex volume of codes into a single line of code which is clear to understand, simple to use, modular and reusable.

Let's look at a simple example.

Imagine you want to get request access to camera for doing a task.
Your code will look something like this :

```swift
let mediaType = AVMediaType.video
if AVCaptureDevice.authorizationStatus(for: mediaType) == .notDetermined {
			AVCaptureDevice.requestAccess(for: self.mediaType) { (status) in
				self.turnOnCameraToRecord()
			}
}
else {
	self.turnOnCameraToRecord()
}
```

This code may seem simple, but it has two major drawbacks:

 1. Codes like this that checking user access or authority to something are usually codes that are used many times. Imagine repeating this code in several places in a project. Definitely not what you want.
 2. If you need to access to other types of `AVMediaType`, you need to repeat these bunch of codes for that type.

Let's see how we can make it better.
We can encapsulate all the codes need to check and request user access to some object, into a condition like below:


```swift
public struct MediaCaptureCondition: AOperationCondition {
    
    let mediaType: AVMediaType
    
    public static var key: String = "MediaCapture"
    
    public static var isMutuallyExclusive: Bool = false
    
    public var dependentOperation: AOperation?
    
    /// Initializes `MediaCaptureCondition` with the given media type
    public init(mediaType: AVMediaType) {
        self.mediaType = mediaType
        self.dependentOperation = MediaCapturePermissionOperation(mediaType: self.mediaType)
    }
    
    public func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
        let stauts = AVCaptureDevice.authorizationStatus(for: self.mediaType)
        
        if stauts == .authorized {
            completion(.success)
        }
        else {
			let error = AOperationError(Error(requestedMediaType: mediaType, status: stauts))
            completion(.failure(error))
        }
        
    }
	
}
```
This condition checks and requests user access to the given type of `AVMediaType`. The operation used to request user access is as follows:

```swift
private class MediaCapturePermissionOperation: VoidOperation {

    let mediaType: AVMediaType

    init(mediaType: AVMediaType) {
        self.mediaType = mediaType
    }
    
    override func execute() {
		if AVCaptureDevice.authorizationStatus(for: self.mediaType) == .notDetermined {
			AVCaptureDevice.requestAccess(for: self.mediaType) { (status) in
				self.finish()
			}
		}
		else {
			self.finish()
		}
		
    }
    
}
```
Using this conditon we can write our initial code like below:

```swift
AOperationBlock {
	self.turnOnCameraToRecord()
}
.conditions(MediaCapturePermissionOperation(mediaType: .video))
.add(to: queue)
```
Look how using `MediaCapturePermissionOperation` conditon makes our code shorter and more readable. In addition we can check and request for user access every where in project with just one line of code using hte power of conditions.

### [AOperationCondition](./Basics.md#aoperationcondition)
