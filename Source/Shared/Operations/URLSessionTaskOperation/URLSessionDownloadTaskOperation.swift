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
    
    /**
     Calls the given closure when URLSessionTask did finish.
     - Parameters:
         - handler:
             Given closure which called when task did finish
             - data:
             The data returned by the server.

             - response:
             An object that provides response metadata, such as HTTP headers and status code. If you are making an HTTP or HTTPS request, the returned object is actually an HTTPURLResponse object.

             - error:
             An error object that indicates why the request failed, or nil if the request was successful.
                    
             - finish:
             You should call this inside closure in the place you want the operation being finished. Note that if you do not call this, the operation stays in execute state.
     */
	public func didFinish(_ handler: @escaping URLResponseOperationBlock) {
		URLSessionTaskManager.shared.didFinishDownloadTask(withIdentifier: self.task.taskIdentifier) { (url, response, error) in
			handler(url, response, error) { error in
				self.finishWithError(error)
			}
		}
	}
	
    /// Periodically informs about the download’s progress.
	public func didChangeProgress(_ handler: @escaping ((Progress) -> Swift.Void)) {
		URLSessionTaskManager.shared.didChangeProgressForTask(withIdentifier: self.task.taskIdentifier, progressHandler: handler)
	}

}
