/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

import CoreLocation

@available(OSX 10.15, *)
public extension AOperationError {
	func map(to type: LocationCondition.Error.Type) -> LocationCondition.Error? {
		guard self.state == .conditionFailed, let info = self.info, (info[.key] as! String) == LocationCondition.key, let status = info[LocationCondition.ErrorInfo.authorizationStatus] as? CLAuthorizationStatus, let notAvailables = info[LocationCondition.ErrorInfo.notAvailableServices] as? [LocationCondition.LocationServicesAvailability] else { return nil }
		return LocationCondition.Error(authorizationStatus: status, notAvailableServices: notAvailables)
	}
}

@available(OSX 10.15, *)
extension LocationCondition {
	
	struct ErrorInfo {
		static let authorizationStatus = AOperationError.Info(rawValue: "CLAuthorizationStatus")
		static let notAvailableServices = AOperationError.Info(rawValue: "notAvailableServices")
	}
	
    public struct Error: Swift.Error {
        
        public init(authorizationStatus: CLAuthorizationStatus, notAvailableServices: [LocationCondition.LocationServicesAvailability]) {
            self.authorizationStatus = authorizationStatus
            self.notAvailableServices = notAvailableServices
        }
        
		public let authorizationStatus: CLAuthorizationStatus
		public let notAvailableServices: [LocationServicesAvailability]
	}
	
}

/// A condition for verifying access to the user's location.
@available(OSX 10.15, *)
public struct LocationCondition: AOperationCondition {
    /**
        Declare a new enum instead of using `CLAuthorizationStatus`, because that
        enum has more case values than are necessary for our purposes.
    */
   public enum Usage {
        case whenInUse
        case always
    }
	
	public enum LocationServicesAvailability: Hashable {
		
		case locationServicesEnabled
		
		#if os(iOS) || os(macOS)
		case significantLocationChangeMonitoringAvailable
		case monitoringAvailable(forRegionClass: AnyClass)
		case headingAvailable
		#endif
		
		#if os(iOS)
		case rangingAvailable
		#endif
		
		var isAvailable: Bool {
			
			switch self {
			case .locationServicesEnabled:
				return CLLocationManager.locationServicesEnabled()
				
			case .significantLocationChangeMonitoringAvailable:
				return CLLocationManager.significantLocationChangeMonitoringAvailable()
				
			case let .monitoringAvailable(forRegionClass: regionClass):
				return CLLocationManager.isMonitoringAvailable(for: regionClass)
				
			case .headingAvailable:
				return CLLocationManager.headingAvailable()
				
			#if os(iOS)
			case .rangingAvailable:
				return CLLocationManager.isRangingAvailable()
			#endif
				
			}
			
		}
		
		
		public static func == (lhs: LocationCondition.LocationServicesAvailability, rhs: LocationCondition.LocationServicesAvailability) -> Bool {
			return "\(lhs)" == "\(rhs)"
		}

		public func hash(into hasher: inout Hasher) {
			hasher.combine("\(self)".hashValue)
		}
		
	}
	
	public static let key = "Location"
	static var notAvailableServiceArray: [LocationServicesAvailability] = []
	public static let isMutuallyExclusive = false
    
    let usage: Usage
	let servicesAvailability: Set<LocationServicesAvailability>
	
	public init(usage: Usage, servicesAvailability: Set<LocationServicesAvailability> = []) {
        self.usage = usage
		var services = servicesAvailability
		services.insert(.locationServicesEnabled)
		self.servicesAvailability = services
    }
    
	public func dependencyForOperation(_ operation: AOperation) -> Foundation.Operation? {
        return LocationPermissionOperation(usage: usage)
    }
    
	public func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
//        let enabled = CLLocationManager.locationServicesEnabled()
		let notAvailableServices = self.servicesAvailability.filter { !$0.isAvailable }
		let availlable = notAvailableServices.isEmpty
		
		if !availlable {
			type(of: self).notAvailableServiceArray = Array(notAvailableServices)
		}
		
        let actual = CLLocationManager.authorizationStatus()
        
		var error: AOperationError?

        // There are several factors to consider when evaluating this condition
        switch (availlable, usage, actual) {
            case (true, _, .authorizedAlways):
                // The service is enabled, and we have "Always" permission -> condition satisfied.
                break

            case (true, .whenInUse, .authorizedWhenInUse):
                /*
                    The service is enabled, and we have and need "WhenInUse"
                    permission -> condition satisfied.
                */
                break

            default:
                /*
                    Anything else is an error. Maybe location services are disabled,
                    or maybe we need "Always" permission but only have "WhenInUse",
                    or maybe access has been restricted or denied,
                    or maybe access hasn't been request yet.
                    
                    The last case would happen if this condition were wrapped in a `SilentCondition`.
                */
				let errorInfo: [AOperationError.Info : Any?] =
					[
						.key : type(of: self).key,
						LocationCondition.ErrorInfo.authorizationStatus : actual,
						LocationCondition.ErrorInfo.notAvailableServices : Self.notAvailableServiceArray
				]
				
				error = AOperationError.conditionFailed(with: errorInfo)
        }
        
        if let error = error {
            completion(.failed(error))
        }
        else {
            completion(.satisfied)
        }
    }
}

/**
    A private `AOperation` that will request permission to access the user's location,
    if permission has not already been granted.
*/
@available(OSX 10.15, *)
private class LocationPermissionOperation: AOperation {
    let usage: LocationCondition.Usage
    var manager: CLLocationManager?
    
    init(usage: LocationCondition.Usage) {
        self.usage = usage
        super.init()
        /*
            This is an operation that potentially presents an alert so it should
            be mutually exclusive with anything else that presents an alert.
        */
        addCondition(AlertPresentation())
    }
    
    override func execute() {
        /*
            Not only do we need to handle the "Not Determined" case, but we also
            need to handle the "upgrade" (.WhenInUse -> .Always) case.
        */
        switch (CLLocationManager.authorizationStatus(), usage) {
            case (.notDetermined, _), (.authorizedWhenInUse, .always):
                DispatchQueue.main.async {
                    self.requestPermission()
                }

            default:
                finish()
        }
    }
    
    fileprivate func requestPermission() {
        manager = CLLocationManager()
        manager?.delegate = self

        let key: String
		#if os(macOS)
			key = "NSLocationAlwaysUsageDescription"
			manager?.requestAlwaysAuthorization()
		#else
        switch usage {
            case .whenInUse:
                key = "NSLocationWhenInUseUsageDescription"
                manager?.requestWhenInUseAuthorization()
			
            case .always:
                key = "NSLocationAlwaysUsageDescription"
                manager?.requestAlwaysAuthorization()
        }
		#endif
        
        // This is helpful when developing the app.
        assert(Bundle.main.object(forInfoDictionaryKey: key) != nil, "Requesting location permission requires the \(key) key in your Info.plist")
    }
    
}

@available(OSX 10.15, *)
extension LocationPermissionOperation: CLLocationManagerDelegate {
    @objc func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if manager == self.manager && isExecuting && status != .notDetermined {
            finish()
        }
    }
}
