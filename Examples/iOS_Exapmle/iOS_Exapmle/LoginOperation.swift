//
//  LoginOperation.swift
//  iOS_Exapmle
//
//  Created by Seyed Samad Gholamzadeh on 1/30/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//
import Foundation
import AOperation
import UIKit

class LoginOperation: AOperation, LoginViewControllerDelegate {
	
	override func execute() {
		switch appState {
		case .logIn:
			finishWithError(nil)
			
		case .logOut:

			DispatchQueue.main.async {
				let app = UIApplication.shared
				let topVC = app.topViewController()
				let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as! LoginViewController
				loginVC.delegate = self
				topVC!.present(loginVC, animated: true, completion: nil)
			}
			
		}
	}
	
	
	func loginViewControllerDidLogin() {
		appState = .logIn
		finishWithError(nil)
	}
	
	func loginViewControllerDidCancel() {
		let error = NSError(code: AOperationError.Code.executionFailed, userInfo: [AOperationError.reason:"Wrong user or password"])
		finishWithError(error)
	}

	
}


struct LoginCondition: AOperationCondition {
	
	static var name: String = "Login"
	
	static var isMutuallyExclusive: Bool = true
	
	func dependencyForOperation(_ operation: AOperation) -> Operation? {
		return LoginOperation()
	}
	
	func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
		
		var error: NSError?

		if appState != .logIn {
			error = NSError(code: .conditionFailed, userInfo: [
				OperationConditionKey: type(of: self).name,
				"UserIsLogged": false
				])
		}

		if let error = error {
			completion(.failed(error))
		}
		else {
			completion(.satisfied)
		}

	}

}


enum AppState {
	case logOut, logIn
}


var appState = AppState.logOut


class GOp: OrderedGroupOperation {
	
	override init(operations: [Operation]) {
		super.init(operations: [])
		
	}
}
