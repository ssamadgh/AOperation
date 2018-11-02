/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Shows how to retrieve the user's location with an operation.
*/

import Foundation
import CoreLocation
import AOperation

/**
    `LocationOperation` is an `Operation` subclass to do a "one-shot" request to
    get the user's current location, with a desired accuracy. This operation will
    prompt for `WhenInUse` location authorization, if the app does not already
    have it.
*/
class LocationOperation: AOperation, CLLocationManagerDelegate {
    // MARK: Properties
    
    fileprivate let accuracy: CLLocationAccuracy
    fileprivate var manager: CLLocationManager?
    fileprivate let handler: (CLLocation) -> Void
    
    // MARK: Initialization
 
    init(accuracy: CLLocationAccuracy, locationHandler: @escaping (CLLocation) -> Void) {
        self.accuracy = accuracy
        self.handler = locationHandler
        super.init()
		let newCondition = LocationCondition(usage: .always, servicesAvailability: [.headingAvailable])
		
        addCondition(LocationCondition(usage: .whenInUse))
        addCondition(MutuallyExclusive<CLLocationManager>())
    }
    
    override func execute() {
        DispatchQueue.main.async {
            /*
                `CLLocationManager` needs to be created on a thread with an active
                run loop, so for simplicity we do this on the main queue.
            */
            let manager = CLLocationManager()
            manager.desiredAccuracy = self.accuracy
            manager.delegate = self
            manager.startUpdatingLocation()
            
            self.manager = manager
        }
    }
    
    override func cancel() {
        DispatchQueue.main.async {
            self.stopLocationUpdates()
            super.cancel()
        }
    }
    
    fileprivate func stopLocationUpdates() {
        manager?.stopUpdatingLocation()
        manager = nil
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy <= accuracy else {
            return
        }
        
        stopLocationUpdates()
        handler(location)
        finishWithError(nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stopLocationUpdates()
        finishWithError(error as NSError?)
    }
}
