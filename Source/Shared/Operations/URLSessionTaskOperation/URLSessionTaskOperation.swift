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
	
	private var task: URLSessionTask!
	
    public static func dataTask(for request: URLRequest, completionHandler: @escaping DataResponseOperationBlock) -> URLSessionTaskOperation {
		return URLSessionTaskOperation(dataFor: request, completionHandler: completionHandler)
	}
	
    public static func downloadTask(for  request: URLRequest, progress: ((Progress) -> Swift.Void)? = nil, completionHandler: @escaping URLResponseOperationBlock) -> URLSessionTaskOperation {
		return URLSessionTaskOperation(downloadFor: request, progress: progress, completionHandler: completionHandler)
	}
	
	public static func uploadTask(for request: URLRequest, from localURL: URL?, progress: ((Progress) -> Swift.Void)? = nil, completionHandler: @escaping  DataResponseOperationBlock) -> URLSessionTaskOperation {
		return URLSessionTaskOperation(uploadFor: request, from: localURL, progress: progress, completionHandler: completionHandler)
	}
	
    convenience init(dataFor request: URLRequest, completionHandler: @escaping DataResponseOperationBlock) {
		self.init(kind: .data, for: request, urlCompletionHandler: nil, dataCompletionHandler: completionHandler)
	}
	
    convenience init(downloadFor request: URLRequest, progress: ((Progress) -> Swift.Void)?, completionHandler: @escaping URLResponseOperationBlock) {
		self.init(kind: .download, for: request, progress: progress, urlCompletionHandler: completionHandler, dataCompletionHandler: nil)
	}
	
    convenience init(uploadFor request: URLRequest, from localURL: URL?, progress: ((Progress) -> Swift.Void)?, completionHandler: @escaping DataResponseOperationBlock) {
		self.init(kind: .upload, from: localURL, for: request, progress: progress, urlCompletionHandler: nil, dataCompletionHandler: completionHandler)
	}

	
	
	private init(kind: TaskKind, from localURL: URL? = nil, for request: URLRequest, progress: ((Progress) -> Swift.Void)? = nil, urlCompletionHandler: URLResponseOperationBlock?, dataCompletionHandler: DataResponseOperationBlock?) {
		super.init()

		let task = URLSessionTaskManager.shared.transportTask(kind: kind, for: request, downloadProgress: progress, urlCompletionHandler: { (url, response, error) in
			
            guard let urlResponse = urlCompletionHandler else {
                self.finishWithError(nil)
                return
            }
            
            urlResponse(url, response, error) { error in
                self.finishWithError(error)
            }
			
		}, dataCompletionHandler: { (data, response, error) in
			
            guard let dataResponse = dataCompletionHandler else {
                self.finishWithError(nil)
                return
            }
            
            dataResponse(data, response, error) { error in
                self.finishWithError(error)
            }

		})
		
//		#if os(iOS) || os(macOS) || os(tvOS)
//		let reachabilityCondition = ReachabilityCondition(url: request.url!)
//		self.addCondition(reachabilityCondition)
//		#endif

		#if os(iOS)
			let networkObserver = NetworkObserver()
			self.addObserver(networkObserver)
		#endif

		
		assert(task.state == .suspended, "Tasks must be suspended.")
		self.task = task

		addObserver(BlockObserver(cancelHandler: { _,_  in
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

