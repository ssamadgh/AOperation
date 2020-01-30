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

extension AOperationError {
    
    /// Maps `AOperationError` to `ReachabilityCondition.Error` type
    public func map(to type: ReachabilityCondition.Error.Type) -> ReachabilityCondition.Error? {
        guard (self.info?[.key] as? String) == ReachabilityCondition.key
         else { return nil }
        return ReachabilityCondition.Error(url: self.info?[ReachabilityCondition.ErrorInfo.url] as? URL, connection: self.info?[ReachabilityCondition.ErrorInfo.connection] as? Connection)
    }
    
    
}

extension ReachabilityCondition {
    struct ErrorInfo {
        static let url = AOperationError.Info(rawValue: "Host")
        static let connection = AOperationError.Info(rawValue: "connection")
    }
    
    /// a `ReachabilityCondition` error
    public struct Error {
       public let url: URL?
       public let connection: Connection?
    }
}

/**
This is a condition that performs a very high-level reachability check.
It performs a long-running reachability check, and it respond to changes in reachability.
If user sets `waitToConnect` to **true**, this condition adds a dependency operation to the operation which this condition is attached to it and that operation waits until the connection changes to the user's intended connection.
If user sets `waitToConnect` to **false**, reachability is evaluated once when the operation to which this is attached is asked about its readiness.
*/

public struct ReachabilityCondition: AOperationCondition {
    
	
	public static let urlKey = "URL"
	public static let key = "Reachability"
	public static let isMutuallyExclusive = false
	
	public let url: URL?
	let connection: Connection?
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
        self.dependentOperation = waitToConnect ? ReachabilityOperation(url: self.url, connection: self.connection) : nil
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
			let error = AOperationError.conditionFailed(with: [.key: Self.key, Self.ErrorInfo.url : self.url])
			
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
//		NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
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
		
//		NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        
        self.reachability.didChangeConnection { [weak self] (connection) in
            guard let `self` = self else { return }
            
            if self.connection == nil {
                if self.reachability.connection != .none {
                    self.reachability.stopNotifier()
                        self.finishWithError(nil)
                    }
                }
                else {
                if self.reachability.connection == self.connection {
                    self.reachability.stopNotifier()
                        self.finishWithError(nil)
                    }
                }
            
        }
		
		do {
			try self.reachability.startNotifier()
		}
		catch {
			
			self.finishWithError(nil)
		}
		
		
	}
	
	@objc func reachabilityChanged(note: Notification) {
		
		let reachability = note.object as! Reachability
		
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

#endif
