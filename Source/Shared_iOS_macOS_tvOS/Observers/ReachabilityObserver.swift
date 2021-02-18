//
//  ReachabilityObserver.swift
//  AOperation
//
//  Created by Seyed Samad Gholamzadeh on 11/26/20.
//

#if os(iOS) || os(macOS) || os(tvOS)

import Foundation

/// This is an observer that performs a very high-level reachability observing.
///
/// Use this observer to react on reachablility change during the operation execution
public struct ReachabilityObserver: AOperationObserver {
	
	private let reachability: Reachability
	
	private var reachabilityHandler: ((Connection) -> Void)?
	
	init(reachability: Reachability? = nil, _ handler: @escaping (Connection) -> Void) {
		self.reachability = reachability ?? Reachability()!
		self.reachabilityHandler = handler
	}
	
	public func operationDidStart(_ operation: AOperation) {
		if let handler = self.reachabilityHandler {
			self.reachability.didChangeConnection(handler)
		}
	}
	
	public func operation(_ operation: AOperation, didProduceOperation newOperation: Operation) {
		//...
	}
	
	public func operationDidFinish(_ operation: AOperation, errors: [AOperationError]) {
		//...
	}
	
	
}

public extension AOperation {
	
	/// This is an observer that performs a very high-level reachability observing.
	///
	/// Use this observer to react on reachablility change during the operation execution
	@discardableResult
	func didChangeReachability(handler: @escaping (AOperation, Connection) -> Void) -> Self {
		addObserver(ReachabilityObserver { [weak self] (connection) in
			guard let `self` = self else { return }
			handler(self, connection)
		})
		return self
	}
	
}


#endif
