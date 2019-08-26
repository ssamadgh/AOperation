//
//  URLSessionDownloadTaskOperation.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 8/26/19.
//

import Foundation

public class URLSessionDownloadTaskOperation: URLSessionTaskOperation {
	
	init(request: URLRequest) {
		super.init(kind: .download, for: request)
		URLSessionTaskManager.shared.didFinishDownloadTask(withIdentifier: self.task.taskIdentifier) { (_, _, _) in
			self.finishWithError(nil)
		}
	}
	
	public func didFinish(_ handler: @escaping URLResponseOperationBlock) {
		URLSessionTaskManager.shared.didFinishDownloadTask(withIdentifier: self.task.taskIdentifier) { (url, response, error) in
			handler(url, response, error) { error in
				self.finishWithError(error)
			}
		}
	}
	
	public func didChangeProgress(_ handler: @escaping ((Progress) -> Swift.Void)) {
		URLSessionTaskManager.shared.didChangeProgressForTask(withIdentifier: self.task.taskIdentifier, progressHandler: handler)
	}

}
