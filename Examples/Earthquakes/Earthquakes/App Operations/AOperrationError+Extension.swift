//
//  AOperrationError+Extension.swift
//  MyOperationPractice
//
//  Created by Seyed Samad Gholamzadeh on 9/15/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import AOperation
import Foundation


extension NSError {
	
	func mapToAOperatonError(state: AOperationError.State, key: String) -> AOperationError {
		var info: [AOperationError.Info : Any?] = [.key : key, .localizedDescription: localizedDescription, .reason : localizedFailureReason]
		for (key, value) in self.userInfo {
			info[AOperationError.Info(rawValue: key)] = value
		}
		let error: AOperationError
		
		switch state {
		case .conditionFailed:
			error = AOperationError.conditionFailed(with: info)
		case .executionFailed:
			error = AOperationError.executionFailed(with: info)
		}
		
		return error
	}
	
}
