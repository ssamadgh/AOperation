//
//  ResultableServicesTaskOperation.swift
//  a5km3
//
//  Created by Seyed Samad Gholamzadeh on 3/10/20.
//  Copyright © 2020 Sishemi. All rights reserved.
//

/*
Abstract:
Here are some of operation that used to fetch data from twitter server.
*/


import Foundation
import AOperation


//Here we used WrapperOperation to add some config to given URLRequest.
//See also how condition used to make sure
//AuthorizedResultableServicesTaskOperation will executes only if authorization key is avialable.


/// A wrapper operation that added authorization key on **HTTPHeaderFields** of
/// given URLRequest, and pass it to **ResultableServicesTaskOperation**.
public class AuthorizedResultableServicesTaskOperation<Output: Decodable>: WrapperOperation<Void, Output> {
	
	init(request: URLRequest) {
		super.init { (_) -> ResultableOperation<Output>? in
			var request = request
			var headers = request.allHTTPHeaderFields ?? [:]
			headers["Authorization"] = ServiceToken.authentication
			request.allHTTPHeaderFields = headers
			return ResultableServicesTaskOperation<Output>(request: request)
		}
		
//		 We add an AuthorizationAvailableCondition() to this operaton
//		 to make sure authorization key is available
//		 otherwise request user to authorize app before operation executes
		addCondition(AuthorizationAvailableCondition())
	}
}



/// A wrraper operation used to fetch json data of given URLRequest and decode it
/// to a model of given type as result of operation.
public class ResultableServicesTaskOperation<Output: Decodable>: WrapperOperation<Void, Output> {
	
	init(request: URLRequest) {
		super.init { (_) -> ResultableOperation<Output>? in
			// Here we used a WrapperOperation to wrap a chain of three operations into one operation.
			return URLSessionTaskOperation.data(for: request)
				.deliver(to:ServicesErrorHandleOperation())
				.deliver(to: JSONDecoderOperation<Output>())
		}
	}
}
