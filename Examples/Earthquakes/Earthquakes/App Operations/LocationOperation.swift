/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Shows how to retrieve the user's location with an operation.
*/

import CoreLocation
import AOperation

/**
    `LocationOperation` is an `Operation` subclass to do a "one-shot" request to
    get the user's current location, with a desired accuracy. This operation will
    prompt for `WhenInUse` location authorization, if the app does not already
    have it.
*/
class LocationOperation: ResultableOperation<CLLocation>, CLLocationManagerDelegate {
    // MARK: Properties
    
    fileprivate let accuracy: CLLocationAccuracy
    fileprivate var manager: CLLocationManager?
    
    // MARK: Initialization
 
    init(accuracy: CLLocationAccuracy) {
        self.accuracy = accuracy
        super.init()
		let locationCondition = LocationCondition(usage: .always, servicesAvailability: [.headingAvailable])
		
        conditions(locationCondition, MutuallyExclusive<CLLocationManager>())
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
		finish(with: .success(location))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stopLocationUpdates()
        
        let operationError = AOperationError(error)
        
		finish(with: .failure(operationError))
    }
}
