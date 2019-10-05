/*
  DownloadEarthquakesOperation.swift
  OperationPractice

  Created by Seyed Samad Gholamzadeh on 7/3/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
     this file contains the code to download the feed of recent earthquakes.
 */

import Foundation
import AOperation

class DownloadEarthquakesOperation: GroupOperation {
    //MARK: Properties
    
    let cacheFile: URL
    
    //MARK: Initializer
    
    /// -parameter cacheFile: The file `URL` to wich  the earthquake feed will be downloaded.
    init(cacheFile: URL) {
        self.cacheFile = cacheFile
        super.init(operations: [])
        name = "Download Earthquakes"
        
        /*
             Since this server is out of our control and does not offer a secure
             communication channel, we'll use the http version of the URL and have
             added "earthquake.usgs.gov" to the "NSExceptionDomains" value in the
             app's info.plist file. When you communicate with your own servers,
             or when the services you use offer secure communication options, you
             should always prefer to use https.
        */
        let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.geojson")!
		let request = URLRequest(url: url)
        
		let taskOperation = URLSessionTaskOperation.download(for: request)
		
		taskOperation.didFinish { (url, response, error, finish) in
            self.downloadFinished(url, response: response, error: error, finish: finish)

		}
		
        let reachabilityCondition = ReachabilityCondition(url: url)
        taskOperation.addCondition(reachabilityCondition)
        
        let networkObserver = NetworkObserver()
        taskOperation.addObserver(networkObserver)
        
        addOperation(taskOperation)
    }
    
	func downloadFinished(_ url: URL?, response: URLResponse?, error: Error?, finish: (AOperationError?) -> Void) {
		
		defer {
			finish(nil)
		}
		
        if let localURL = url {
            do {
                /*
                     If we already have a file at this location, just delete it.
                     Also swallow the error, because we don't really care about it.
                */
                try FileManager.default.removeItem(at: cacheFile)
            }
            catch { }
            
            do {
                try FileManager.default.moveItem(at: localURL, to: cacheFile)
            }
            catch let error as NSError {
				let opError = AOperationError.executionFailed(with: [.key: self.name, .localizedDescription : error.localizedDescription])
                aggregateError(opError)
            }
        }
        else if let error = error {
			let opError = AOperationError.executionFailed(with: [.key: self.name, .localizedDescription : error.localizedDescription])

            aggregateError(opError)
        }
        else {
            // Do nothing, and the operation will automatically finish.
        }
    }
	
}
