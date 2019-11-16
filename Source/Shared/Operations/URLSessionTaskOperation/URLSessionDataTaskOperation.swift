//
//  URLSessionDataTaskOperation.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 8/26/19.
//

import Foundation

public class URLSessionDataTaskOperation: URLSessionTaskOperation {
	
	init(request: URLRequest) {
		super.init(kind: .data, for: request)
		URLSessionTaskManager.shared.didFinishDataTask(withIdentifier: self.task.taskIdentifier) { (_, _, _) in
            self.finishWithError(nil)
		}
	}
	
    /**
     Calls the given closure when URLSessionTask did finish.
     - Parameters:
         - handler:
             Given closure which called when task did finish
             - location:
             The location of a temporary file where the server’s response is stored. You must move this file or open it for reading before your completion handler returns. Otherwise, the file is deleted, and the data is lost.

             - response:
             An object that provides response metadata, such as HTTP headers and status code. If you are making an HTTP or HTTPS request, the returned object is actually an HTTPURLResponse object.

             - error:
             An error object that indicates why the request failed, or nil if the request was successful.
                    
             - finish:
             You should call this inside closure in the place you want the operation being finished. Note that if you do not call this, the operation stays in execute state.

     */
	public func didFinish(_ handler: @escaping DataResponseOperationBlock) {
        let request = self.task.originalRequest!
        let task = URLSessionTaskManager.shared.didFinishDataTask(withRequest: request) { (data, response, error) in
            handler(data, response, error) { error in
                self.finishWithError(error)
            }
        }
        
        self.task = task
        
	}
	
}
