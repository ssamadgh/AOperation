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

public class URLSessionTaskOperation: AOperation {
	
	private var task: URLSessionTask!
	
	public static func dataTask(for request: URLRequest, completionHandler: @escaping  ((Data?, URLResponse?, Error?) -> Swift.Void)) -> URLSessionTaskOperation {
		return URLSessionTaskOperation(dataFor: request, completionHandler: completionHandler)
	}
	
	public static func downloadTask(for  request: URLRequest, progress: ((Progress) -> Swift.Void)? = nil, completionHandler: @escaping  ((URL?, URLResponse?, Error?) -> Swift.Void)) -> URLSessionTaskOperation {
		return URLSessionTaskOperation(downloadFor: request, progress: progress, completionHandler: completionHandler)
	}
	
	public static func uploadTask(for request: URLRequest, from localURL: URL?, progress: ((Progress) -> Swift.Void)? = nil, completionHandler: @escaping  ((Data?, URLResponse?, Error?) -> Swift.Void)) -> URLSessionTaskOperation {
		return URLSessionTaskOperation(uploadFor: request, from: localURL, progress: progress, completionHandler: completionHandler)
	}
	
	convenience init(dataFor request: URLRequest, completionHandler: @escaping  ((Data?, URLResponse?, Error?) -> Swift.Void)) {
		self.init(kind: .data, for: request, urlCompletionHandler: {_,_,_ in }, dataCompletionHandler: completionHandler)
	}
	
	convenience init(downloadFor request: URLRequest, progress: ((Progress) -> Swift.Void)?, completionHandler: @escaping  ((URL?, URLResponse?, Error?) -> Swift.Void)) {
		self.init(kind: .download, for: request, progress: progress, urlCompletionHandler: completionHandler, dataCompletionHandler: {_,_,_ in })
	}
	
	convenience init(uploadFor request: URLRequest, from localURL: URL?, progress: ((Progress) -> Swift.Void)?, completionHandler: @escaping  ((Data?, URLResponse?, Error?) -> Swift.Void)) {
		self.init(kind: .upload, from: localURL, for: request, progress: progress, urlCompletionHandler: {_,_,_ in }, dataCompletionHandler: completionHandler)
	}

	
	
	private init(kind: TaskKind, from localURL: URL? = nil, for request: URLRequest, progress: ((Progress) -> Swift.Void)? = nil, urlCompletionHandler: @escaping ((URL?, URLResponse?, Error?) -> Swift.Void), dataCompletionHandler: @escaping ((Data?, URLResponse?, Error?) -> Swift.Void)) {
		super.init()

		let task = URLSessionTaskManager.shared.transportTask(kind: kind, from: localURL, for: request, downloadProgress: progress, urlCompletionHandler: { (url, response, error) in
			
			if let error = error as NSError? {
				self.finishWithError(error as NSError?)
			}
			else {
				urlCompletionHandler(url, response, error)
				self.finishWithError(error as NSError?)
			}
			
		}, dataCompletionHandler: { (data, response, error) in
			
			if let error = error as NSError? {
				self.finishWithError(error as NSError?)
			}
			else {
				dataCompletionHandler(data, response, error)
				self.finishWithError(error as NSError?)
			}
			
		})
		
		#if os(iOS) || os(macOS) || os(tvOS)
		let reachabilityCondition = ReachabilityCondition(host: request.url!)
		self.addCondition(reachabilityCondition)
		#endif

		#if os(iOS)
			let networkObserver = NetworkObserver()
			self.addObserver(networkObserver)
		#endif

		
		assert(task.state == .suspended, "Tasks must be suspended.")
		self.task = task

		addObserver(BlockObserver(cancelHandler: { _ in
			task.cancel()
		}))

		name = "URLSessionTaskOperation"
	}
	
	
	//    init(task: URLSessionTask) {
	//        assert(task.state == .suspended, "Tasks must be suspended.")
	//        self.task = task
	//        super.init()
	//        name = "URLSessionTaskOperation"
	//    }
	
	deinit {
		print("URLSessionTaskOperation deinited")
	}
	
	override public func execute() {
		
		assert(task.state == .suspended, "Task was resumed by something other than \(self).")
		
		task.resume()
	}
	
}

