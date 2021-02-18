//
//  URLSessionDownloadTaskOperation.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 8/26/19.
//

import Foundation

/// A subclass of ResultableOperation that handles URLSessionDownloadTask request and result
public class URLSessionDownloadTaskOperation: URLSessionTaskBaseOperation<(url: URL, response: URLResponse)>, RetryableOperation {
	
	public func new() -> Self {
		URLSessionDownloadTaskOperation(request: request) as! Self
	}
	
	init(request: URLRequest) {
		super.init(kind: .download, for: request)
		URLSessionTaskManager.shared.didFinishDownloadTask(withIdentifier: self.task.taskIdentifier) { [weak self] (url, response, error) in
			guard let `self` = self else { return }
			let result: Result<(url: URL, response: URLResponse), AOperationError>
			
			if let url = url, let response = response {
				result = .success((url, response))
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
    	
    /// Periodically informs about the download’s progress.
	@discardableResult
	public func didChangeProgress(_ handler: @escaping ((Progress) -> Swift.Void)) -> Self {
		URLSessionTaskManager.shared.didChangeProgressForTask(withIdentifier: self.task.taskIdentifier, progressHandler: handler)
		return self
	}

}
