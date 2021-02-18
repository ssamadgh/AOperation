//
//  RequestAuthorizationOperation.swift
//  ESL
//
//  Created by Seyed Samad Gholamzadeh on 8/13/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

/*
Abstract:
In this file operations for checking and requesting twitter authorization are implemented.

*/


import Foundation
import AOperation
import UIKit

/// An empty struct used as generic key to making **CheckAuthorizationOperation** mutual exclusive
struct MutuallyRequestAccessToken {
	
}


/// An operation for checking twitter authorization status.
/// This operation is used as dependentOperation of **AuthorizationAvailableCondition**.
/// We adopt to this operation `UniqueOperation` to prevent any other authorization execute concurrently.
class CheckAuthorizationOperation: VoidOperation, UniqueOperation {
	
	var uniqueId: String {
		"\(type(of: self))"
	}
	
	
	override init() {
		super.init()
	}
	
	override func execute() {
		// We check authorization status here
		switch ServiceToken.state {
		case .available:
		// If the app currently is authorized we call finish() method to finish operation.
			finish()
			return
		case .unavailable:
		// If the app is not authorized we request for authorization
			requestAuthorization()
		}
		
	}
	
	weak var registerVC: UIViewController?
	
	func requestAuthorization() {
		// To request authorization we present RegisterationViewController.
		DispatchQueue.main.async {
			let registerVC = RegisterationViewController()
			registerVC.delegate = self
			let nav = UINavigationController(rootViewController: registerVC)
			let presenter = UIApplication.shared.topViewController()
			presenter?.present(nav, animated: true, completion: nil)
			self.registerVC = registerVC
		}
	}
	
	override func cancel() {
		// If the operation did cancel and register view controller
		// is still in present, we should dismiss it.
		registerVC?.dismiss(animated: true, completion: nil)
		super.cancel()
	}

	
}

extension CheckAuthorizationOperation: RegisterationViewControllerDelegate {
	
	func registerationViewControllerDidFinishRegisteration() {
		// If registeration did finish in RegisterationViewController
		// we finish operatoin to AuthorizationAvailableCondition start to evaluation.
		self.finish()
	}
	
	func registerationViewControllerDidCancelRegisteration() {
		// If registeration did cancel in RegisterationViewController
		// we cancel the operation, by this a cancel error will publish
		// and AuthorizationAvailableCondition evaluation fails
		self.cancel()
	}
}

private let authorizationBody = "grant_type=client_credentials"

struct AuthorizationModel: Decodable {
	
	private let tokenType: String
	private let accessToken: String
	
	var authorization: String {
		tokenType + " " + accessToken
	}
	
	enum CodingKeys: String, CodingKey {
		case tokenType = "token_type"
		case accessToken = "access_token"
	}
	
}


/// An operation that handles requesting twitter authorization
class RequestAuthorizationOperation: WrapperOperation<Void, ServiceToken.State> {
	
	init(_ credentials: TwitterApi.Credentials) {
		// We used WrapperOperation type for this operation to wrap
		// some of URLRequest configs needed for authorization url server
		// and also the chain of operations we used to handle authorization task
		// in one single operation.
		// This way we have some encapsulated and more clean and readable codes
		// at the end of project
		super.init { (_) -> ResultableOperation<ServiceToken.State>? in
			//Some URLRequest configs we need for requesting authorization.
			let url = URL(string: "https://api.twitter.com/oauth2/token")!
			var request = URLRequest(url: url)
			request.httpMethod = URLRequest.HTTPMethod.post
			request.httpBody = authorizationBody.data(using: .utf8, allowLossyConversion: false)
			let authorizationValue = "Basic " + (credentials.key + ":" + credentials.secretKey)
				.data(using: .utf8, allowLossyConversion: false)!
				.base64EncodedString()
			request.allHTTPHeaderFields = [
				"Authorization" : authorizationValue,
				"Content-Type" : "application/x-www-form-urlencoded;charset=UTF-8"
			]
			
			// A Chain of operations we used to handle authorization
			// Because of we do not want to give authorization key as result directly, we used an operation to save authorization key
			// and also maping the authorization key result to authorization availability result.
			// In other words we used StoringAuthorizationInfoOperation
			// to change type of final result that will publish by RequestAuthorizationOperation.
			return
				ResultableServicesTaskOperation<AuthorizationModel>(request: request)
				.deliver(to: StoringAuthorizationInfoOperation())
		}
	}
	
}


/// An operation that gets authorization key as receivedValue and stors it in memory and published status of authoriaztion availability as result.
class StoringAuthorizationInfoOperation: ResultableOperation<ServiceToken.State>, ReceiverOperation {
	
	internal var receivedValue: Result<AuthorizationModel, AOperationError>?
	
	override func execute() {
		guard let value = self.receivedValue else {
			self.finish(with: .failure(.receivedValueIsNil(in: self)))
			return
		}
		
		switch value {
		case .success(let auth):
			ServiceToken.authentication = auth.authorization
			self.finish(with: .success(ServiceToken.state))
		case .failure(let error):
			self.finish(with: .failure(error))
		}
	}
}
