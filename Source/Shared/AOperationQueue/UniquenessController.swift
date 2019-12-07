//
//  uniquenessController.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 12/6/19.
//

import Foundation

class UniquenessController {
	
    internal static let shared = UniquenessController()

    fileprivate let serialQueue = DispatchQueue(label: "Operations.UniquenessController", attributes: [])
    fileprivate var operationsKey: Set<String> = []

    fileprivate init() {
        /*
         A private initializer effectively prevents any other part of the app
         from accidentally creating an instance.
         */
    }

    internal func addOperation(_ operation: AOperation) {
        /*
         This needs to be a synchronous operation.
         If this were async, then we might not get around to adding dependencies
         until after the operation had already begun, which would be incorrect.
         */
        serialQueue.sync {
			self.operationsKey.insert(type(of: operation).key)
        }
    }

    /// Unregisters an operation from being mutually exclusive.
    internal func removeOperation(_ operation: AOperation) {
        serialQueue.async {
			self.operationsKey.remove(type(of: operation).key)
        }
    }
	
	internal func contains(_ operation: AOperation) -> Bool {
        /*
         This needs to be a synchronous operation.
         If this were async, then we might not get around to adding dependencies
         until after the operation had already begun, which would be incorrect.
         */
		serialQueue.sync {
			self.operationsKey.contains(type(of: operation).key)
        }
    }
	
}
