/*
  ParseEarthquakesOperation.swift
  OperationPractice

  Created by Seyed Samad Gholamzadeh on 7/5/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
     Contains the logic to parse a JSON file of earthquakes and insert them into an NSManagedObjectContext
*/

import Foundation
import CoreData
import AOperation

/// A struct to represent a parsed earthquake.
private struct ParsedEarthquake {
    //MARK: Properties
    
    let date: Date
    
    let identifier, name, link: String
    
    let depth, latitude, longitude, magnitude: Double
    
    //MARK: Initializer
    
    init?(feature: [String: Any]) {
        guard let earthquakeID = feature["id"] as? String, !earthquakeID.isEmpty else { return nil }
        identifier = earthquakeID
        
        let properties = feature["properties"] as? [String: Any] ?? [:]
        
        name = properties["place"] as? String ?? ""
        
        link = properties["url"] as? String ?? ""
        
        magnitude = properties["mag"] as? Double ?? 0.0
        
        if let offset = properties["time"] as? Double {
            date = Date(timeIntervalSince1970: offset/1000)
        }
        else {
            date = Date.distantFuture
        }
        
        let geometry = feature["geometry"] as? [String: Any] ?? [:]
        
        if let coordinates = geometry["coordinates"] as? [Double], coordinates.count == 3 {
            longitude = coordinates[0]
            latitude = coordinates[1]
            
            // `depth` is in km, but we want to store it in meters.
            depth = coordinates[2]*1000
        }
        else {
            longitude = 0
            latitude = 0
            depth = 0
        }
    }
}

/// An`Operation` to parse earthquakes out of a download feed from the USGS.
class ParseEarthquakesOperation: VoidOperation, ReceiverOperation {
	
	
	var receivedValue: Result<(URL, URLResponse), AOperationError>?

    let context: NSManagedObjectContext
    
    /**
     - parameter cacheFile: The file `URL` from which to load earthquake data.
     - parameter context: The `NSManagaedObjectContext` that will be used as the
         basis for importing data. The operation will internally construct a new
         `NSManagedObjectContext` that points to the same `NSPersistentStoreCoordinator`
         as the passed-in context.
    */
    init(context: NSManagedObjectContext) {
        let importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        
        /*
             Use the overwrite merge policy, because we want any updated ubjects
             to replace the ones in the store.
        */
        importContext.mergePolicy = NSOverwriteMergePolicy
        
        self.context = importContext
        
        super.init()
        
        name = "Parse Earthquakes"
 
    }
    
    override func execute() {
		let receivedUrl: URL?
		switch receivedValue {
		case let .success((url, _)):
			receivedUrl = url
			
		case let .failure(error):
			receivedUrl = nil
			self.finish(error)
			return
		case .none:
			receivedUrl = nil
		}
		
		guard let cacheFile = receivedUrl else {
			return
		}
		
        guard let stream = InputStream(url: cacheFile) else  {
            finish()
            return
        }
        
        stream.open()
        
        defer {
            stream.close()
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: stream, options: []) as? [String: Any]
            
            if let features = json?["features"] as? [[String: Any]] {
                parse(features)
            }
            else {
			   finish()
            }
        }
        catch let jsonError {
			let opError = AOperationError(jsonError)
            finish(opError)
        }
    }
    
    fileprivate func parse(_ features: [[String: Any]]) {
		let parsedEarthquakes = features.compactMap { ParsedEarthquake(feature: $0) }
        
        context.perform {
            for newEarthquake in parsedEarthquakes {
                self.insert(newEarthquake)
            }
            
            let error = self.saveContext()
            self.finish(error)
        }
    }
    
    fileprivate func insert(_ parsed: ParsedEarthquake) {
        let earthquake = NSEntityDescription.insertNewObject(forEntityName: Earthquake.entityName, into: context) as! Earthquake
        earthquake.identifier = parsed.identifier
        earthquake.timestamp = parsed.date
        earthquake.latitude = parsed.latitude
        earthquake.longitude = parsed.longitude
        earthquake.depth = parsed.depth
        earthquake.webLink = parsed.link
        earthquake.name = parsed.name
        earthquake.magnitude = parsed.magnitude
    }
    /**
         Save the context, if there are any changes.
     
     - returns: An `NSError` if there was an problem saving the `NSManagedObjectContext`,
         otherwise `nil`.
     - note: This method returns an `NSError?` because it will be immediately
         passed to the `finishWithError()` method, wich accepts an `NSError?`.
    */
    fileprivate func saveContext() -> AOperationError? {
        var error: AOperationError?
        
        if context.hasChanges {
            do {
                try context.save()
            }
            catch let saveError {
				let opError = AOperationError(saveError)
                error = opError
            }
        }
        
        return error
    }
    
}
