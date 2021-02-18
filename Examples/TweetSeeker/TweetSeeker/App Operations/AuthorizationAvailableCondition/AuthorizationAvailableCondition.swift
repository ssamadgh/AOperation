//
//  AccessTokenExistCondition.swift
//  ESL
//
//  Created by Seyed Samad Gholamzadeh on 8/13/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import AOperation


/// A condition that used to check and request for twitter authorization.
/// This condition adds **CheckAuthorizationOperation** as dependency to the main operation. After finishing of this dependent operation, condition checks availabality of authorizaion key, then it succeeds or fails the evaluation.
struct AuthorizationAvailableCondition: AOperationCondition {
	
	struct Error: LocalizedError {
		var errorDescription: String? {
			"Unable to authorize. Please check your apiKey and apiSecret"
		}
	}

	var dependentOperation: AOperation? = CheckAuthorizationOperation()
	
    static var isMutuallyExclusive: Bool = true
    
    // We check if authorization is available or not, to succeed condition evaluation.
    func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
        
        switch ServiceToken.state {
        case .available:
            completion(.success)
        default:
            
            let error = AOperationError(Error())
			let errors = self.dependentOperation?.publishedErrors
            completion(.failure(errors?.first ?? error))
        }
        
    }
    
}
