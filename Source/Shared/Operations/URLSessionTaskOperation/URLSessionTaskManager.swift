//
//  URLSessionTaskManager.swift
//  iVisit
//
//  Created by Seyed Samad Gholamzadeh on 11/28/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation




public extension URLRequest {
	
	struct HTTPMethod {
		
		public static var get = "GET"
		public static var post = "POST"
		public static var put = "PUT"
		public static var delete = "DELETE"
	}
	
}

class URLSessionTaskManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
	
	enum TaskKind {
		case data, download, upload
	}
	
	public static var shared: URLSessionTaskManager = {
		return URLSessionTaskManager()
	}()

	var downloadTaskFinisedDic: [Int : (URL?, URLResponse?, Error?) -> Swift.Void] = [:]
	var dataTaskFinisedDic: [Int : (Data?, URLResponse?, Error?) -> Swift.Void] = [:]
	var taskProgressDic: [Int : (Progress) -> Swift.Void] = [:]
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		print("Hello, totalBytesWritten, totalBytesExpectedToWrite ")
		let progress: Progress
		
//		if #available(iOS 11, tvOS 11.0, OSX 10.13, watchOSApplicationExtension 4.0, *) {
//			progress = downloadTask.progress
//		} else {
		progress = Progress(totalUnitCount: totalBytesExpectedToWrite)
		progress.completedUnitCount = totalBytesWritten
//		}
		
		let taskProgress = self.taskProgressDic[downloadTask.taskIdentifier]
		taskProgress?(progress)
	}
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

		let url = location
		let response = downloadTask.response
		let error = downloadTask.error
//		self.downloadTaskFinised?(url, response, error)
		let downloadTaskFinised = self.downloadTaskFinisedDic[downloadTask.taskIdentifier]
		downloadTaskFinised?(url, response, error)
		self.taskProgressDic.removeValue(forKey: downloadTask.taskIdentifier)
		self.downloadTaskFinisedDic.removeValue(forKey: downloadTask.taskIdentifier)
	}
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
		
		print("uploading data didSendBodyData")
		let progress: Progress
//		if #available(iOS 11, tvOS 11.0, OSX 10.13, watchOSApplicationExtension 4.0, *) {
//			progress = task.progress
//		} else {
			progress = Progress(totalUnitCount: totalBytesExpectedToSend)
			progress.completedUnitCount = totalBytesSent
//		}

		let taskProgress = self.taskProgressDic[task.taskIdentifier]
		taskProgress?(progress)
	}
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		print("task Finished didCompleteWithError")
		let response = task.response
		let error = error

		if let dataTaskFinised = self.dataTaskFinisedDic[task.taskIdentifier] {
			dataTaskFinised(nil, response, error)
			self.dataTaskFinisedDic.removeValue(forKey: task.taskIdentifier)
			self.taskProgressDic.removeValue(forKey: task.taskIdentifier)
			return
		}
		
		if let downloadTaskFinished = self.downloadTaskFinisedDic[task.taskIdentifier] {
			downloadTaskFinished(nil, response, error)
			self.dataTaskFinisedDic.removeValue(forKey: task.taskIdentifier)
			self.taskProgressDic.removeValue(forKey: task.taskIdentifier)
			return
		}

	}
	
	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		print("task Finished didReceive data")
		let response = dataTask.response
		let error = dataTask.error
//		self.uploadTaskFinised?(data, response, error)
		
		let dataTaskFinised = self.dataTaskFinisedDic[dataTask.taskIdentifier]
		dataTaskFinised?(data, response, error)
		self.dataTaskFinisedDic.removeValue(forKey: dataTask.taskIdentifier)
		self.taskProgressDic.removeValue(forKey: dataTask.taskIdentifier)
	}
	
	private lazy var session: URLSession = {
		
		let configuration = URLSessionConfiguration.default
		let session = URLSession(configuration: configuration, delegate:self , delegateQueue: nil)
		
		return session
	}()
	
//	func getData(kind: TaskKind = .download, from localURL: URL? = nil, for request: URLRequest, downloadProgress: ((Progress) -> Swift.Void)? = nil, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Swift.Void, uploadCompletionHandler: ((Data?, URLResponse?, Error?) -> Swift.Void)? = nil) -> URLSessionTaskOperation {
//		
//		let task = transportTask(kind: kind, from: localURL, for: request, downloadProgress: downloadProgress, completionHandler: completionHandler, uploadCompletionHandler: uploadCompletionHandler)
//		
//		return operation(for: task, with: request.url!)
//	}
	
	func transportTask(kind: TaskKind, for request: URLRequest) -> URLSessionTask {
		
		switch kind {
		case .data:

			let task = session.dataTask(with: request)
//			self.dataTaskFinisedDic[task.taskIdentifier] = dataCompletionHandler

			return task
			
		case .download:
			
			let deownloadTask = session.downloadTask(with: request)
//			self.downloadTaskFinisedDic[deownloadTask.taskIdentifier] = urlCompletionHandler
//			self.taskProgressDic[deownloadTask.taskIdentifier] = downloadProgress
			
			return deownloadTask

		case .upload:
			
			let upload = session.uploadTask(withStreamedRequest: request)
//			self.dataTaskFinisedDic[upload.taskIdentifier] = dataCompletionHandler
//			self.taskProgressDic[upload.taskIdentifier] = downloadProgress
			
			return upload
			
			
		}

	}

	
	func didFinishDataTask(withIdentifier taskIdentifier: Int, completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Swift.Void)) {
		self.dataTaskFinisedDic[taskIdentifier] = completionHandler
	}
	
	func didFinishDownloadTask(withIdentifier taskIdentifier: Int, completionHandler: @escaping ((URL?, URLResponse?, Error?) -> Swift.Void)) {
		self.downloadTaskFinisedDic[taskIdentifier] = completionHandler
	}
	
	func didChangeProgressForTask(withIdentifier taskIdentifier: Int, progressHandler: @escaping ((Progress) -> Swift.Void)) {
		self.taskProgressDic[taskIdentifier] = progressHandler
	}
	
	
}

