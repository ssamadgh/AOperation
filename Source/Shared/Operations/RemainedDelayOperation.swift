/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how to make an operation that efficiently waits from remaining time.
*/

#if os(iOS)

import Foundation


/**
	`RemainedDelayOperation` is a subclass of `ResultableOperation` that will simply wait for a remained time from a given time
	interval.

	When `RemainedDelayOperation` initializes, it records absolute time of initiailize and when the operation  starts to execute it calcualtes current absolute time difference to the initialize absolut time
	and it waits for remained time from the given time or finishes if remained time is less than or equal to 0.

	It is important to note that this operation does **not** use the `sleep()`
	function, since that is inefficient and blocks the thread on which it is called.
	Instead, this operation uses `dispatch_after` to know when the appropriate amount
	of time has passed.

	- Note: Set the Output as Void to use this operation independently. If you set Output other than 	Void type you should use this opeation as subscriberOperation. In this case the operation directly 	results the received value.

*/
public class RemainedDelayOperation<Output>: ResultableOperation<Output>, ReceiverOperation {
    

	// MARK: Properties
	public var receivedValue: Result<Output, AOperationError>?
    private var initialAbsoluteTime: CFAbsoluteTime!
    private var timer: AOperationTimer!
    
    private let timeOut: TimeInterval
    
	// MARK: Initialization
	
    public init(timeOut: TimeInterval) {
        self.timeOut = timeOut
        super.init()
        self.initialAbsoluteTime = CFAbsoluteTimeGetCurrent()
    }
    
	public override func execute() {
        let currentAbsoluteTime = CFAbsoluteTimeGetCurrent()
        let diff: TimeInterval = max(timeOut - (currentAbsoluteTime - self.initialAbsoluteTime), 0)
        self.timer = AOperationTimer(interval: diff) {
            //notify view here
			self.finish()
        }
    }
	
	func finish() {
		if Output.self == Void.self {
			self.finish(with: .success(Void() as! Output))
			return
		}
		
		guard let result = self.receivedValue else {
			fatalError("Set the Output type to Void or use this operation as a subscriberOperation")
		}
		self.finish(with: result)
	}
    
}

#endif
