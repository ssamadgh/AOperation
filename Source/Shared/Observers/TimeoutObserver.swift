/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how to implement the OperationObserver protocol.
*/

import Foundation

extension TimeoutObserver {
	struct ErrorInfo {
		static let timeout = AOperationError.Info(rawValue: "Timeout")
	}
}

/**
    `TimeoutObserver` is a way to make an `Operation` automatically time out and
    cancel after a specified time interval.
*/
struct TimeoutObserver: OperationObserver {
    // MARK: Properties

    
    fileprivate let timeout: TimeInterval
    
    // MARK: Initialization
    
    init(timeout: TimeInterval) {
        self.timeout = timeout
    }
    
    // MARK: OperationObserver
    
    internal func operationDidStart(_ operation: AOperation) {
        // When the operation starts, queue up a block to cause it to time out.
		let when = DispatchTime.now() + timeout
		
		DispatchQueue.global(qos: DispatchQoS.QoSClass.default).asyncAfter(deadline: when) {
            /*
                Cancel the operation if it hasn't finished and hasn't already
                been canceled.
            */
            if !operation.isFinished && !operation.isCancelled {
				let info: [AOperationError.Info : Any?] =
				[
					type(of: self).ErrorInfo.timeout : self.timeout
				]
				let error = AOperationError.executionFailed(with: info)

                operation.finishWithError(error)
            }
        }
    }
	
	func operationDidCancel(_ operation: AOperation, errors: [AOperationError]) {
		// No op.
	}

    internal func operation(_ operation: AOperation, didProduceOperation newOperation: Foundation.Operation) {
        // No op.
    }

    internal func operationDidFinish(_ operation: AOperation, errors: [AOperationError]) {
        // No op.
    }
}
