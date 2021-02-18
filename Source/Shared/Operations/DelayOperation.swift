/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how to make an operation that efficiently waits.
*/

import Foundation

/**
    `DelayOperation` is a `ResultableOperation` that will simply wait for a given time
    interval, or until a specific `Date`.

    It is important to note that this operation does **not** use the `sleep()`
    function, since that is inefficient and blocks the thread on which it is called.
    Instead, this operation uses `dispatch_after` to know when the appropriate amount
    of time has passed.

    If the interval is negative, or the `NSDate` is in the past, then this operation
    immediately finishes.

	- Note: Set the Output as Void to use this operation independently. If you set Output other than Void type you should use this opeation as subscriberOperation. In this case the operation directly results the received value.
*/
public class DelayOperation<Output>: ResultableOperation<Output>, ReceiverOperation {
	
	// MARK: Types
	fileprivate enum Delay {
		case interval(TimeInterval)
		case date(Foundation.Date)
	}
	
	// MARK: Properties
	public var receivedValue: Result<Output, AOperationError>?
	fileprivate let delay: Delay
	
	// MARK: Initialization
	
	public init(_ interval: TimeInterval) {
		delay = .interval(interval)
		super.init()
	}
	
	public init(until date: Date) {
		delay = .date(date)
		super.init()
	}
	
	override public func execute() {
		let interval: TimeInterval
		
		// Figure out how long we should wait for.
		switch delay {
		case .interval(let theInterval):
			interval = theInterval
			
		case .date(let date):
			interval = date.timeIntervalSinceNow
		}
		
		guard interval > 0 else {
			finish()
			return
		}
		
		let when = DispatchTime.now() + Double(Int64(interval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
		DispatchQueue.global(qos: DispatchQoS.QoSClass.default).asyncAfter(deadline: when) {
			// If we were canceled, then finish() has already been called.
			if !self.isCancelled {
				self.finish()
			}
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
