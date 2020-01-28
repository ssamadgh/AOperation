//
//  CoreDataController.swift
//  iVisit
//
//  Created by Seyed Samad Gholamzadeh on 11/27/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import CoreData
import AOperation

class CoreDataStack {
	
	static var shared: CoreDataStack!
	
	var container: NSPersistentContainer
	
	var viewContext: NSManagedObjectContext {
		return container.viewContext
	}
	
	init(_ modelName: String, completionClosure: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
		container = NSPersistentContainer(name: modelName)
		print(NSPersistentContainer.defaultDirectoryURL().path)
		container.loadPersistentStores() { (description, error) in
			if let error = error {
				fatalError("Failed to load Core Data stack: \(error)")
			}
			completionClosure(description, error)
		}
	}
	
}


class InitializeCoreDataStackOperation: AOperation {
	
	private var stack: CoreDataStack!
	
	let modelName: String
	
	init(modelName: String) {
		self.modelName = modelName
		super.init()
	}
	
	override func execute() {
		
		guard CoreDataStack.shared == nil else {
			finishWithError(nil)
			return
		}
		
		stack = CoreDataStack(self.modelName) { description, error in
            
            
            let cdError: AOperationError? = error != nil ? AOperationError.executionFailed(with: [.key : self.name, .localizedDescription : error!.localizedDescription, .reason : description]) : nil
                
			self.finishWithError(cdError)
		}
	}
	
	override func finished(_ errors: [AOperationError]) {
		if errors.isEmpty {
			CoreDataStack.shared = stack
		}
	}
	
}

struct CoreDataStackAvailablity: AOperationCondition {
    
    
    var dependentOperation: AOperation?
    
	
	let modelName: String
	
	init(modelName: String) {
		self.modelName = modelName
        self.dependentOperation = InitializeCoreDataStackOperation(modelName: modelName)
	}
	
//	static var key: String = "CoreDataStackAvailablity"
	
	static var isMutuallyExclusive: Bool = true
	
	func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
		let result: OperationConditionResult
		
		if CoreDataStack.shared != nil {
			result = .satisfied
		}
		else {
            let error = AOperationError.conditionFailed(with: [.key : Self.key])

            result = .failed(error)
		}
		
		completion(result)
	}

}
