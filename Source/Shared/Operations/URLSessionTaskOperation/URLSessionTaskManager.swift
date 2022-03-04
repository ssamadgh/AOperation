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

/// A class that wrapped URLSessionTaskManager and its functions
class URLSessionTaskManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
	
	enum TaskKind {
		case data, download, upload
	}
	
	public static var shared: URLSessionTaskManager = {
		return URLSessionTaskManager()
	}()
	
	fileprivate let serialQueue = DispatchQueue(label: "Operations.URLSessionTaskManager", attributes: [])
	
	var downloadTaskFinishedDic: [Int : (URL?, URLResponse?, Error?) -> Swift.Void] = [:]
	var dataTaskFinishedDic: [Int : (Data?, URLResponse?, Error?) -> Swift.Void] = [:]
	var taskProgressDic: [Int : (Progress) -> Swift.Void] = [:]
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		
		let progress: Progress
		
		progress = Progress(totalUnitCount: totalBytesExpectedToWrite)
		progress.completedUnitCount = totalBytesWritten
		var taskProgress: ((Progress) -> Void)?
		serialQueue.sync {
			taskProgress = self.taskProgressDic[downloadTask.taskIdentifier]
		}
		taskProgress?(progress)
	}
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		
		let url = location
		let response = downloadTask.response
		let error = downloadTask.error
		
		var downloadTaskFinished: ((URL?, URLResponse?, Error?) -> Void)?
		serialQueue.sync {
			downloadTaskFinished = self.downloadTaskFinishedDic[downloadTask.taskIdentifier]
		}
		
		downloadTaskFinished?(url, response, error)
		
		serialQueue.async {
			self.taskProgressDic.removeValue(forKey: downloadTask.taskIdentifier)
			self.downloadTaskFinishedDic.removeValue(forKey: downloadTask.taskIdentifier)
		}
	}
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
		
		let progress: Progress
		
		progress = Progress(totalUnitCount: totalBytesExpectedToSend)
		progress.completedUnitCount = totalBytesSent
		
		var taskProgress: ((Progress) -> Void)?
		serialQueue.sync {
			taskProgress = self.taskProgressDic[task.taskIdentifier]
		}
		taskProgress?(progress)
	}
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		
		let response = task.response
		let error = error
		
		if let dataTaskFinished: ((Data?, URLResponse?, Error?) -> Void) = {
			
			var dataTaskFinished: ((Data?, URLResponse?, Error?) -> Void)?
			serialQueue.sync {
				dataTaskFinished = self.dataTaskFinishedDic[task.taskIdentifier]
			}
			return dataTaskFinished
			}() {
			
			dataTaskFinished(nil, response, error)
			
			serialQueue.async {
				self.dataTaskFinishedDic.removeValue(forKey: task.taskIdentifier)
				self.taskProgressDic.removeValue(forKey: task.taskIdentifier)
			}
			return
		}
		
		if let downloadTaskFinished: (URL?, URLResponse?, Error?) -> Void = {
			
			var downloadTaskFinished: ((URL?, URLResponse?, Error?) -> Void)?
			serialQueue.sync {
				downloadTaskFinished = self.downloadTaskFinishedDic[task.taskIdentifier]
			}
			
			return downloadTaskFinished
			
			}() {
			downloadTaskFinished(nil, response, error)
			serialQueue.async {
				self.dataTaskFinishedDic.removeValue(forKey: task.taskIdentifier)
				self.taskProgressDic.removeValue(forKey: task.taskIdentifier)
			}
			return
		}
		
	}
	
	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		
		let response = dataTask.response
		let error = dataTask.error
		
		if let dataTaskFinished: ((Data?, URLResponse?, Error?) -> Void) = {
			var dataTaskFinished: ((Data?, URLResponse?, Error?) -> Void)?
			serialQueue.sync {
			dataTaskFinished = self.dataTaskFinishedDic[dataTask.taskIdentifier]
			}
			return dataTaskFinished
			}() {
			
			dataTaskFinished(data, response, error)
			
			serialQueue.async {
				self.dataTaskFinishedDic.removeValue(forKey: dataTask.taskIdentifier)
				self.taskProgressDic.removeValue(forKey: dataTask.taskIdentifier)
			}
		}
		
   
		

      
	}
	
	private lazy var session: URLSession = {
		
		let configuration = URLSessionConfiguration.default
		let session = URLSession(configuration: configuration, delegate:self , delegateQueue: nil)
		
		return session
	}()
	
	
	func transportTask(with kind: TaskKind, for request: URLRequest) -> URLSessionTask? {
		
		switch kind {
		case .data:
			
//			let task = session.dataTask(with: request)
			return nil
			
		case .download:
			
			let deownloadTask = session.downloadTask(with: request)
			return deownloadTask
			
		case .upload:
			
			let upload = session.uploadTask(withStreamedRequest: request)
			return upload
			
			
		}
		
	}
	
	func didFinishDataTask(withIdentifier taskIdentifier: Int, completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Swift.Void)) {
		serialQueue.async {
			self.dataTaskFinishedDic[taskIdentifier] = completionHandler
		}
	}
	
	func didFinishDataTask(withRequest request: URLRequest, completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Swift.Void)) -> URLSessionTask {
		return self.session.dataTask(with: request, completionHandler: completionHandler)
	}
	
	func didFinishDownloadTask(withIdentifier taskIdentifier: Int, completionHandler: @escaping ((URL?, URLResponse?, Error?) -> Swift.Void)) {
		serialQueue.async {
			self.downloadTaskFinishedDic[taskIdentifier] = completionHandler
		}
	}
	
	func didChangeProgressForTask(withIdentifier taskIdentifier: Int, progressHandler: @escaping ((Progress) -> Swift.Void)) {
		serialQueue.async {
			self.taskProgressDic[taskIdentifier] = progressHandler
		}
	}
	
	
}

