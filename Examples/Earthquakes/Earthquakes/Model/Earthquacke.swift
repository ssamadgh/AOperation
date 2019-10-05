/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The Earthquake model object.
 */

import Foundation
import CoreData
import CoreLocation

/*
 An `NSManagedObject` subclass to model basic earthquake properties. This also
 contains some convenience methods to aid in formatting the information.
 */
class Earthquake: NSManagedObject {
    // MARK: Static Properties
    
    static let entityName = "Earthquake"
    
    // MARK: Formatters
    
    static let timestampFormatter: DateFormatter = {
        let timestampFormatter = DateFormatter()
        
        timestampFormatter.dateStyle = .medium
        timestampFormatter.timeStyle = .medium
        
        return timestampFormatter
    }()
    
    static let magnitudeFormatter: NumberFormatter = {
        let magnitudeFormatter = NumberFormatter()
        
        magnitudeFormatter.numberStyle = .decimal
        magnitudeFormatter.maximumFractionDigits = 1
        magnitudeFormatter.minimumFractionDigits = 1
        
        return magnitudeFormatter
    }()
    
    static let depthFormatter: LengthFormatter = {
        
        let depthFormatter = LengthFormatter()
        depthFormatter.isForPersonHeightUse = false
        
        return depthFormatter
    }()
    
    static let distanceFormatter: LengthFormatter = {
        let distanceFormatter = LengthFormatter()
        
        distanceFormatter.isForPersonHeightUse = false
        distanceFormatter.numberFormatter.maximumFractionDigits = 2
        
        return distanceFormatter
    }()
    
    // MARK: Properties
    
    @NSManaged var identifier: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var name: String
    @NSManaged var magnitude: Double
    @NSManaged var timestamp: Date
    @NSManaged var depth: Double
    @NSManaged var webLink: String
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var location: CLLocation {
        return CLLocation(coordinate: coordinate, altitude: -depth, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: timestamp)
    }
}
