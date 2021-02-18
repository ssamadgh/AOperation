//
//  ServicesErrorHandleOperation.swift
//  TweetSeeker
//
//  Created by Seyed Samad Gholamzadeh on 1/22/21.
//

import Foundation
import AOperation

/// A model used to decode server error messages
public struct MessageResponse: Decodable {
	let message: String?
}

/// An error type used to generate received server error messages as error
public struct ServiceError: LocalizedError {
	
	public let rawValue: Int
	public let message: String
	init(_ rawValue: Int, _ message: String) {
		self.rawValue = rawValue
		self.message  = message
	}
	
	public var errorDescription: String? {
		message
	}
	
}

/// An operation used to check if received HTTPURLResponse statusCode is
/// in a valid domain otherwise generates received error message from server
/// and publishes it as an error
public class ServicesErrorHandleOperation: ResultableOperation<Data>, ReceiverOperation {
	
	public var receivedValue: Result<(Data, URLResponse), AOperationError>?
	
	public override func execute() {
		
		guard let value = receivedValue else {

			finish(with: .failure(.receivedValueIsNil(in: self)))
			return
		}
		
		switch value {
		case let .success((data, response)):
			guard let response = (response as? HTTPURLResponse) else {
				//If response is not HTTPURLResponse so we do not need to check status code
				finish(with: .success(data))
				return
			}
			let statusCode = response.statusCode
			if (statusCode >= 200 && statusCode <= 299) {
				finish(with: .success(data))
			}
			else {
				let message = try! JSONDecoder().decode(MessageResponse.self, from: data).message
				let error = ServiceError(statusCode, message ?? "Unkown Error")
				finish(with: .failure(AOperationError(error)))
			}
		case .failure(let error):
			finish(with: .failure(error))
		}
		
	}
	
}

