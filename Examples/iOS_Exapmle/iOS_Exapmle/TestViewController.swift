//
//  TestViewController.swift
//  iOS_Exapmle
//
//  Created by Seyed Samad Gholamzadeh on 8/26/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import AOperation
import CoreLocation

class TestViewController: UIViewController {
	
	let operationQueue = AOperationQueue()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		var request = URLRequest(url: URL(string: "https://jsonplaceholder.typicode.com/todos/1")!)

//		var request = URLRequest(url: URL(string: "https://jsonplaceholdertypicode.comtodos1")!)
		
//		let operation = URLSessionDataTaskOperation(request: request)
//		operation.didFinish { (data, response, error, finished) in
//			print("recieved data is \(String(data: data!, encoding: .utf8))")
//			finished(nil)
//		}
		
//		let operation = URLSessionTaskOperation.download(with: request)
//		operation.didFinish { (url, response, error, finished) in
//			print("recieved url )")
//			finished(nil)
//
//		}
		request.httpMethod = URLRequest.HTTPMethod.post
		request.httpBody = "Helllo".data(using: .utf8)
		let operation = URLSessionTaskOperation.upload(for: request)
		operation.didFinish { (data, response, error, finished) in
			print("did Finish")
			finished(nil)
		}
		
		operation.didChangeProgress { (progress) in
			print("did change to fraction \(progress.fractionCompleted)")

		}
		self.operationQueue.addOperation(operation)
        
//        let condition: Error = LocationCondition.Error(authorizationStatus: .notDetermined, notAvailableServices: [])
        let authorizationStatus = AOperationError.Info(rawValue: "CLAuthorizationStatus")
        let notAvailableServices = AOperationError.Info(rawValue: "notAvailableServices")

        let errorInfo: [AOperationError.Info : Any?] =
            [
                .key : LocationCondition.key,
                authorizationStatus : CLAuthorizationStatus.denied,
                notAvailableServices : []
        ]
        
        let error = AOperationError.conditionFailed(with: errorInfo)

        let conditionError = error.map(to: LocationCondition.Error.self)
        
	}
	
}