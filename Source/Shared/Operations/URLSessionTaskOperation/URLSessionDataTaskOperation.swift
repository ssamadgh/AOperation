//
//  URLSessionDataTaskOperation.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 8/26/19.
//

import Foundation

/// A subclass of ResultableOperation that handles URLSessionDataTask request and result
public class URLSessionDataTaskOperation: URLSessionTaskBaseOperation<(data: Data, response: URLResponse)>, RetryableOperation {
	
	public func new() -> Self {
		URLSessionDataTaskOperation(request: request) as! Self
	}
		
	init(request: URLRequest) {
		super.init(kind: .data, for: request)
		
		let task = URLSessionTaskManager.shared.didFinishDataTask(withRequest: request) { [weak self] (data, response, error) in
			
			guard let `self` = self else { return }
			let result: Result<(data: Data, response: URLResponse), AOperationError>
			
			if let data = data, let response = response {
				result = .success((data, response))
			}
			else {
				if let error = error {
					result = .failure(AOperationError(error))
				}
				else {
					let error: URLError = URLError(URLError.Code.unknown)
					result = .failure(AOperationError(error))
				}
			}
			
			self.finish(with: result)

		}
		
		self.task = task
	}
		
}
