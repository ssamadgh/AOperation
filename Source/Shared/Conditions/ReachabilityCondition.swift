//
//  ReachabilityCondition.swift
//  AOperation
//
//  Created by Seyed Samad Gholamzadeh on 3/9/19.
//
/*
Abstract:
This file shows an example of implementing the OperationCondition protocol.

*/

import Foundation

extension ReachabilityCondition {
	struct ErrorInfo {
		static let host = AOperationError.Info(rawValue: "Host")
	}
}

/**
This is a condition that performs a very high-level reachability check.
It performs a long-running reachability check, and it respond to changes in reachability.
If user sets `waitToConnect` to **true**, this condition adds a dependency operation to the operation which this condition is attached to it and that operation waits until the connection changes to the user's intended connection.
If user sets `waitToConnect` to **false**, reachability is evaluated once when the operation to which this is attached is asked about its readiness.
*/

public struct ReachabilityCondition: AOperationCondition {
	
	public static let hostKey = "Host"
	public static let name = "Reachability"
	public static let isMutuallyExclusive = false
	
	public let url: URL?
	let connection: Connection?
	let waitToConnect: Bool
	
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
		If user sets this parameter to **true**, the condition adds a dependency operation to the operation which this condition is attached to it and that operation waits until the connection changes to the user's intended connection.
		If user sets this parameter to **false**, reachability is evaluated once when the operation to which this is attached is asked about its readiness.
		The default value is **false**.
	*/
	public init(url: URL? = nil, connection: Connection? = nil, waitToConnect: Bool = false) {
		self.url = url
		self.connection = connection
		self.waitToConnect = waitToConnect
		
		guard let reachability = Reachability(hostname: self.url?.host) else {
			fatalError("Reachability is nil")
		}
		self.reachability = reachability
	}
	
	public func dependencyForOperation(_ operation: AOperation) -> Foundation.Operation? {
		return waitToConnect ? ReachabilityOperation(url: self.url, connection: self.connection) : nil
	}
	
	
	
	public func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
		
		var isConnect: Bool = false
		
		
		if self.connection == nil {
			let reachable = self.reachability.connection != .none
			isConnect = reachable
		}
		else {
			isConnect = self.connection == self.reachability.connection
		}
		
		
		if isConnect {
			completion(.satisfied)
		}
		else {
			let error = AOperationError.conditionFailed(with: [.key: Self.name, Self.ErrorInfo.host : self.url?.host])
			
			completion(.failed(error))

		}
		
	}
	
	
}


private class ReachabilityOperation: AOperation {
	public let url: URL?
	let connection: Connection?
	
	private let reachability: Reachability
	
	init(url: URL?, connection: Connection?) {
		self.url = url
		self.connection = connection
		
		guard let reachability = Reachability(hostname: self.url?.host) else {
			fatalError("Reachability is nil")
		}
		self.reachability = reachability
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
	}
	
	override func execute() {
		
		var isConnect: Bool = false
		
		if self.connection == nil {
			let reachable = self.reachability.connection != .none
			isConnect = reachable
		}
		else {
			isConnect = self.reachability.connection == self.connection
		}
		
		guard !isConnect else {
			self.finishWithError(nil)
			return
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
		
		do {
			try self.reachability.startNotifier()
		}
		catch {
//			let errorInfo: [AOperationError.Info : Any?] =
//			[
//				.key : type(of: self).name
//			]
//			let error = NSError(code: .conditionFailed, userInfo: [
//				"Operation": self.name ?? "",
//				"HOST": self.url?.host ?? ""
//				])
			
			self.finishWithError(nil)
		}
		
		
	}
	
	@objc func reachabilityChanged(note: Notification) {
		
		let reachability = note.object as! Reachability
		
//		switch reachability.connection {
//		case .wifi:
//			print("Reachable via WiFi")
//		case .cellular:
//			print("Reachable via Cellular")
//		case .none:
//			print("Network not reachable")
//		}
		
		if self.connection == nil {
			if reachability.connection != .none {
				reachability.stopNotifier()
				self.finishWithError(nil)
			}
		}
		else {
			if reachability.connection == self.connection {
				reachability.stopNotifier()
				self.finishWithError(nil)
			}
		}
		
	}


}
