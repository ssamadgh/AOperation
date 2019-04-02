/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 This file defines the error codes and convenience functions for interacting with AOperation-related errors.
 */

import Foundation


public struct AOperationError {
	public static let domain = "OperationErrors"
	public static let reason = "OperationErrorsReason"
	
	public enum Code: Int {
		case conditionFailed = 1
		case executionFailed = 2
	}

}
//public let OperationErrorDomain = "OperationErrors"

struct AOperationError2: CustomNSError {
	
	var errorCode: Int
	var errorUserInfo: [String : Any]
	
	init(code: Int, userInfo: [String: Any]? = nil) {
		errorCode = code
		errorUserInfo = userInfo ?? [:]
	}
	
}

extension NSError {
    public convenience init(code: AOperationError.Code, userInfo: [String: Any]? = nil) {
        self.init(domain: AOperationError.domain, code: code.rawValue, userInfo: userInfo)
    }
}

// This makes it easy to compare an `NSError.code` to an `OperationErrorCode`.
func ==(lhs: Int, rhs: AOperationError.Code) -> Bool {
    return lhs == rhs.rawValue
}

func ==(lhs: AOperationError.Code, rhs: Int) -> Bool {
    return lhs.rawValue == rhs
}

//extension Error {
//
//	init(code: OperationErrorCode, userInfo: [String: Any]? = nil) {
//		self.init(domain: OperationErrorDomain, code: code.rawValue, userInfo: userInfo)
//	}
//
//}

