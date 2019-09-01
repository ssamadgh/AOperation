/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This file shows how to implement the OperationObserver protocol.
 */

import Foundation

/**
 The `BlockObserver` is a way to attach arbitrary blocks to significant events
 in an `AOperation`'s lifecycle.
 */
public struct BlockObserver: OperationObserver {
    // MARK: Properties

    fileprivate let startHandler: ((AOperation) -> Void)?
    fileprivate let produceHandler: ((AOperation, Foundation.Operation) -> Void)?
    fileprivate let finishHandler: ((AOperation, [AOperationError]) -> Void)?

    public init(startHandler: ((AOperation) -> Void)? = nil, produceHandler: ((AOperation, Foundation.Operation) -> Void)? = nil, finishHandler: ((AOperation, [AOperationError]) -> Void)? = nil) {
        self.startHandler = startHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
    }

    // MARK: OperationObserver

	public func operationDidStart(_ operation: AOperation) {
        startHandler?(operation)
    }
	
    public func operation(_ operation: AOperation, didProduceOperation newOperation: Foundation.Operation) {
        produceHandler?(operation, newOperation)
    }

   public func operationDidFinish(_ operation: AOperation, errors: [AOperationError]) {
        finishHandler?(operation, errors)
    }
}

