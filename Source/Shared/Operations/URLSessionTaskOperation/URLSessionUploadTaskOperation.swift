//
//  URLSessionUploadTaskOperation.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 8/26/19.
//

import Foundation

/// A subclass of ResultableOperation that handles URLSessionUploadTask request and result
public class URLSessionUploadTaskOperation: URLSessionTaskBaseOperation<(data: Data, response: URLResponse)>, RetryableOperation {
	
	public func new() -> Self {
		URLSessionUploadTaskOperation(request: request) as! Self
	}
	
	init(request: URLRequest) {
		super.init(kind: .upload, for: request)
		URLSessionTaskManager.shared.didFinishDataTask(withIdentifier: self.task.taskIdentifier) { [weak self] (data, response, error) in

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
	}
		
    /// Periodically informs the  progress of sending body content to the server.
	@discardableResult
	public func didChangeProgress(_ handler: @escaping ((Progress) -> Swift.Void)) -> Self {
		URLSessionTaskManager.shared.didChangeProgressForTask(withIdentifier: self.task.taskIdentifier, progressHandler: handler)
		return self
	}
	
}
