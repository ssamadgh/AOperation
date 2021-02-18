/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Shows how to lift operation-like objects in to the NSOperation world.
*/


import Foundation


/// A subclass of ResultableOperation that wrappes URLSessionTaskManager and some of its functions
public class URLSessionTaskBaseOperation<Output>: ResultableOperation<Output> {
	
	internal var request: URLRequest
	
	var task: URLSessionTask!
	
	init(kind: URLSessionTaskManager.TaskKind, for request: URLRequest) {
		self.request = request
		super.init()
		if let task = URLSessionTaskManager.shared.transportTask(with: kind, for: request) {
			self.task = task
			
			assert(task.state == .suspended, "Tasks must be suspended.")
		}
		
		#if os(iOS)
		let networkObserver = NetworkObserver()
		self.addObserver(networkObserver)
		#endif
		
	}
		
	override public func execute() {
		guard task.state != .canceling
		else {
			return
		}
		assert(task.state == .suspended, "Task was resumed by something other than \(self).")
		
		task.resume()
	}
	
	/// Cancels The operation and the URLSessin task executes inside it.
	public override func cancel() {
		task.cancel()
		super.cancel()
	}
	
}


/// Provides some static methods for accessing operations that handle  URLSession related tasks like download and upload.
public struct URLSessionTaskOperation {
	
	/**
	Returns a `URLSessionDataTaskOperation` which executes a `URLSessionDataTask` with the given request.
	
	This operation results `(data: Data, response: URLResponse)`

	
	- Parameter request: The `URLRequest` which `URLSessionDataTask` executed with that.
	*/
	public static func data(for request: URLRequest) -> URLSessionDataTaskOperation {
		return URLSessionDataTaskOperation(request: request)
	}
	
	/**
	Returns a `URLSessionDataTaskOperation` which executes a `URLSessionDataTask` with the given url.
	
	This operation results `(data: Data, response: URLResponse)`
	
	- Parameter url: The `URL` which `URLSessionDataTask` executed with that.
	*/
	public static func data(for url: URL) -> URLSessionDataTaskOperation {
		return URLSessionDataTaskOperation(request: URLRequest(url: url))
	}
	
	
	/**
	Returns a `URLSessionUploadTaskOperation` which executes a `URLSessionUploadTask` with the given request.
	
	This operation results `(data: Data, response: URLResponse)`

	
	- Parameter request: The `URLRequest` which `URLSessionUploadTask` executed with that.
	*/
	public static func upload(for request: URLRequest) -> URLSessionUploadTaskOperation {
		return URLSessionUploadTaskOperation(request: request)
	}
	
	/**
	Returns a `URLSessionUploadTaskOperation` which executes a `URLSessionUploadTask` with the given url.
	
	This operation results `(data: Data, response: URLResponse)`
	
	- Parameter url: The `URL` which `URLSessionUploadTask` executed with that.
	*/
	public static func upload(for url: URL) -> URLSessionUploadTaskOperation {
		return URLSessionUploadTaskOperation(request: URLRequest(url: url))
	}
	
	
	/**
	Returns a `URLSessionDownloadTaskOperation` which executes a `URLSessionDownloadTask` with the given request.
	
	This operation results `(url: URL, response: URLResponse)`
	
	- Parameter request: The `URLRequest` which `URLSessionDownloadTask` executed with that.
	*/
	public static func download(for request: URLRequest) -> URLSessionDownloadTaskOperation {
		return URLSessionDownloadTaskOperation(request: request)
	}
	
	/**
	Returns a `URLSessionDownloadTaskOperation` which executes a `URLSessionDownloadTask` with the given url.
	
	This operation results `(url: URL, response: URLResponse)`

	- Parameter request: The `URL` which `URLSessionDownloadTask` executed with that.
	*/
	public static func download(for url: URL) -> URLSessionDownloadTaskOperation {
		return URLSessionDownloadTaskOperation(request: URLRequest(url: url))
	}
	
	
}
