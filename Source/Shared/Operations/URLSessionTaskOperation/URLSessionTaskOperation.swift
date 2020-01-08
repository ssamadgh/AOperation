/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Shows how to lift operation-like objects in to the NSOperation world.
*/

import Foundation

public typealias DataResponseOperationBlock = ( Data?, URLResponse?, Error?, @escaping (AOperationError?) -> Void) -> Void

public typealias URLResponseOperationBlock = ( URL?, URLResponse?, Error?, @escaping (AOperationError?) -> Void) -> Void


/**
`URLSessionTaskOperation` is an `AOperation` that lifts an `NSURLSessionTask`
into an operation.

*/
public class URLSessionTaskOperation: AOperation {
	
	var task: URLSessionTask!
	
    /**
        Returns a `URLSessionDataTaskOperation` which executes a `URLSessionDataTask` with the given request.
     
        - Parameter request: The `URLRequest` which `URLSessionDataTask` executed with that.
     */
	public static func data(for request: URLRequest) -> URLSessionDataTaskOperation {
		return URLSessionDataTaskOperation(request: request)
	}
	
    /**
        Returns a `URLSessionUploadTaskOperation` which executes a `URLSessionUploadTask` with the given request.
     
        - Parameter request: The `URLRequest` which `URLSessionUploadTask` executed with that.
     */
	public static func upload(for request: URLRequest) -> URLSessionUploadTaskOperation {
		return URLSessionUploadTaskOperation(request: request)
	}

    /**
        Returns a `URLSessionDownloadTaskOperation` which executes a `URLSessionDownloadTask` with the given request.
     
        - Parameter request: The `URLRequest` which `URLSessionDownloadTask` executed with that.
     */
	public static func download(for request: URLRequest) -> URLSessionDownloadTaskOperation {
		return URLSessionDownloadTaskOperation(request: request)
	}
    
	init(kind: URLSessionTaskManager.TaskKind, for request: URLRequest) {
		super.init()
		
		let task = URLSessionTaskManager.shared.transportTask(kind: kind, for: request)
		self.task = task

		#if os(iOS)
		let networkObserver = NetworkObserver()
		self.addObserver(networkObserver)
		#endif
		
		
		assert(task.state == .suspended, "Tasks must be suspended.")
		
	}
	
	deinit {
		if AOperation.Debugger.printOperationsState {
			print("\(type(of: self)) deinited")
		}
	}
	
	override public func execute() {
		
		assert(task.state == .suspended, "Task was resumed by something other than \(self).")
		
		task.resume()
	}
    
    /// Cancels The operation and the URLSessin task executes inside it.
	public override func cancel() {
		task.cancel()
		super.cancel()
	}
		
}

