//
//  AppDelegatePresenter.swift
//  iOS_Exapmle
//
//  Created by Seyed Samad Gholamzadeh on 2/2/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import AOperation

class AppDelegatePresenter {
	
	lazy var queue = AOperationQueue()
	
	init() {
		AOperation.Debugger.printOperationsState = true
	}
	
	
	func initializeCoreDataStack(modelName: String, completion: @escaping (_ error: AOperationError?) -> Void ) {
		
		let op = BlockAOperation {
			
		}
		op.addCondition(CoreDataStackAvailablity(modelName: modelName))
		op.addObserver(BlockObserver { _ , errors in
            
			completion(errors.first)
		})
	}
	
}
