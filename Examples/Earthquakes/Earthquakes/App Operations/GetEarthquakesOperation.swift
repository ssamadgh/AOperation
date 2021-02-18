/*
  GetEarthquakesOperation.swift
  OperationPractice

  Created by Seyed Samad Gholamzadeh on 7/3/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
     This file sets up the operation to download and parse earthquakes data. It will also decide to display an error message, if approperiate.
*/

import Foundation
import CoreData
import AOperation

/// A composite `Operation` to both download and parse earthquake data.
class GetEarthquakesOperation: WrapperOperation<Void, Void> {
	
	/**
	 - parameter context: The `NSManagedObjectContext` into wich the parsed earthquakes will be imported.
	*/
	init(context: NSManagedObjectContext) {
		let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.geojson")!
		super.init { (_) -> ResultableOperation<Void>? in
			/*
			 This operation is composite of two child operation:
				 1. The operation to download the JSON feed
				 2. The operation to parse the JSON feed and insert the elements into the Core Data store
			*/
			return URLSessionTaskOperation.download(for: url).deliver(to: ParseEarthquakesOperation(context: context))
		}
		
		delegate = self
		let reachabilityCondition = ReachabilityCondition(url: url)
		conditions(reachabilityCondition)

	}
}

extension GetEarthquakesOperation: AOperationDelegate {
	
	func operationDidFinish(_ operation: AOperation, with errors: [AOperationError]) {
		if let error = errors.first {
			produceAlert(error)
		}
	}
	
	fileprivate func produceAlert(_ error: AOperationError) {
		/*
			 We only want to show the first Error, since subsequent errors might be caused
			 by the first.
		*/
		guard let errorPublisher = error.publisher else { return }

		let alert = AlertOperation()

		//These are example of errors for which we might choose to display an error to the user
		switch errorPublisher {
		case ReachabilityCondition.key:
			// We failed because the network isn't reachable.
			
			let reachErrorURL = (error.publishedError as? ReachabilityCondition.Error)?.url?.absoluteString ?? ""
			alert.title = "Unable to Connect"
			alert.message = "Cannot connect to \(reachErrorURL). Make sure your device is connected to the internet and try again."
			
		default:
			// We failed because the JSON was malformed.
			alert.title = "Unable to Download"
			alert.message = "Cannot download earthquake data. try again later."
			
		}

		produce(alert)
	}

}
