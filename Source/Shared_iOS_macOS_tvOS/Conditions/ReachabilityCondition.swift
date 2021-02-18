//
//  ReachabilityCondition.swift
//  AOperation
//
//  Created by Seyed Samad Gholamzadeh on 3/9/19.
//
/*
Abstract:
This file is about ReachabilityCondition which implementing the OperationCondition protocol.

*/
#if os(iOS) || os(macOS) || os(tvOS)

import Foundation

extension ReachabilityCondition {
	
	/// a `ReachabilityCondition` error
	public struct Error: LocalizedError {
		public let url: URL?
		public let connection: Connection?
		
		public var errorDescription: String? {
			let urlString = url != nil ? "url \(url!.absoluteString)" : "network"
			let connectionString = connection != nil && connection != Connection.none ? "by \(connection!)" : ""
			return "Failed to reach \(urlString) \(connectionString)"
		}
	}
}

/**
This is a condition that performs a very high-level reachability check.

It provides a long-running reachability check, meaning that if current status of connection is different from desired connection status, condition can keep operation on pending till connection status changes.
*/

public struct ReachabilityCondition: AOperationCondition {

	public static let isMutuallyExclusive = false
	
	public let url: URL?
	let connection: Connection
	let waitToConnect: Bool
	
	public var dependentOperation: AOperation?
	
	private let reachability: Reachability
	
	/**
	Initialization for reachability condition
	
	- Parameters:
		- url:
		The url which user wants to chack reachability to it
		The default value is nil
		- connection:
		The type of connection which user wants to have
		If the value of this parameter set to nil, the condition checks if connection is other than **.none**. The default value is nil
		- waitToConnect:
		set this parameter **true**, to keep operation on pending till connection status changes to expected status.
		By setting this parameter to **false**, reachability is evaluated once when the operation to which this is attached is asked about its readiness.
		The default value is **false**.
	*/
	public init(url: URL? = nil, connection: Connection = .any, waitToConnect: Bool = false) {
		self.url = url
		self.connection = connection
		self.waitToConnect = waitToConnect
		
		guard let reachability = Reachability(hostname: self.url?.host) else {
			fatalError("Reachability is nil")
		}
		self.reachability = reachability
		self.dependentOperation = waitToConnect ? ReachabilityOperation(url: self.url, connection: self.connection, reachability: reachability) : nil
	}
	
	public func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
		
		let isConnectionSatisfied: Bool
		
		switch self.connection {
		case .any:
			isConnectionSatisfied =  (self.reachability.connection != .none)
		default:
			isConnectionSatisfied = (self.connection == self.reachability.connection)
		}
		
		if isConnectionSatisfied {
			completion(.success)
		}
		else {
			let error = AOperationError(Error(url: url, connection: connection))
			
			completion(.failure(error))
		}
		
	}
	
	
}


private class ReachabilityOperation: VoidOperation {
	public let url: URL?
	let connection: Connection
	
	private let reachability: Reachability
	
	init(url: URL?, connection: Connection, reachability: Reachability) {
		self.url = url
		self.connection = connection
		
		self.reachability = reachability
	}
	
	deinit {
		//		NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
	}
	
	override func execute() {
		
		let isConnectionSatisfied: Bool
		
		switch self.connection {
		case .any:
			isConnectionSatisfied =  (self.reachability.connection != .none)
		default:
			isConnectionSatisfied = (self.connection == self.reachability.connection)
		}
		
		guard !isConnectionSatisfied else {
			self.finish()
			return
		}
		
		self.reachability.didChangeConnection { [weak self] (connection) in
			guard let `self` = self else { return }
			
			if self.reachability.connection == self.connection {
				self.reachability.stopNotifier()
				self.finish()
			}
			
		}
		
		do {
			try self.reachability.startNotifier()
		}
		catch {
			
			self.finish()
		}
		
	}
	
	
}

#endif
