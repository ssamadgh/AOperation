/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Shows how to lift operation-like objects in to the NSOperation world.
*/

import Foundation


/**
`URLSessionTaskOperation` is an `AOperation` that lifts an `NSURLSessionTask`
into an operation.

Note that this operation does not participate in any of the delegate callbacks \
of an `NSURLSession`, but instead uses Key-Value-Observing to know when the
task has been completed. It also does not get notified about any errors that
occurred during execution of the task.

An example usage of `URLSessionTaskOperation` can be seen in the `DownloadEarthquakesOperation`.
*/

public typealias DataResponseOperationBlock = ( Data?, URLResponse?, Error?, @escaping (NSError?) -> Void) -> Void
public typealias URLResponseOperationBlock = ( URL?, URLResponse?, Error?, @escaping (NSError?) -> Void) -> Void

public class URLSessionTaskOperation: AOperation {
	
	var task: URLSessionTask!
	
	public static func data(for request: URLRequest) -> URLSessionDataTaskOperation {
		return URLSessionDataTaskOperation(request: request)
	}
	
	public static func upload(for request: URLRequest) -> URLSessionUploadTaskOperation {
		return URLSessionUploadTaskOperation(request: request)
	}

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
		
		
		self.observeDidCancel { (_) in
			task.cancel()
		}
		
	}
	
	deinit {
		if AOperationDebugger.printOperationsState {
			print("\(type(of: self)) deinited")
		}
	}
	
	override public func execute() {
		
		assert(task.state == .suspended, "Task was resumed by something other than \(self).")
		
		task.resume()
	}
		
}

