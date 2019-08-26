//
//  URLSessionUploadTaskOperation.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 8/26/19.
//

import Foundation

public class URLSessionUploadTaskOperation: URLSessionTaskOperation {
	
	init(request: URLRequest) {
		super.init(kind: .upload, for: request)
		URLSessionTaskManager.shared.didFinishDataTask(withIdentifier: self.task.taskIdentifier) { (_, _, _) in
			self.finishWithError(nil)
		}
	}
	
	public func didFinish(_ handler: @escaping DataResponseOperationBlock) {
		URLSessionTaskManager.shared.didFinishDataTask(withIdentifier: self.task.taskIdentifier) { (data, response, error) in
			handler(data, response, error) { error in
				self.finishWithError(error)
			}
		}
	}
	
	public func didChangeProgress(_ handler: @escaping ((Progress) -> Swift.Void)) {
		URLSessionTaskManager.shared.didChangeProgressForTask(withIdentifier: self.task.taskIdentifier, progressHandler: handler)
	}
	
}
