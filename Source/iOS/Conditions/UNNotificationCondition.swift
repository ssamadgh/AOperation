/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

#if os(iOS)

import UserNotifications


@available(iOS 10.0, *)
extension UNNotificationCondition {
    
   public struct Error: LocalizedError {
        let currentOptions: UNAuthorizationOptions
        let desiredOptions: UNAuthorizationOptions
		let authorizationStatus: UNAuthorizationStatus
	
	public var errorDescription: String? {
		if authorizationStatus == .denied {
			return "UserNotification authorization is denied"
		}
		else {
			return "UserNotification Authorization is \(authorizationStatus) for \(currentOptions) and is not authorized for \(desiredOptions)"
		}
		
	}
	
    }
    
}

@available(iOS 10.0, *)
/**
	A condition for verifying that is it available to present alerts to the user via
	**[User Notifications](https://developer.apple.com/documentation/usernotifications/)** .
*/
public struct UNNotificationCondition: AOperationCondition {

    public var dependentOperation: AOperation?
    
    public enum Behavior {
        /// Merge the new `UIUserNotificationSettings` with the `currentUserNotificationSettings`.
        case merge

        /// Replace the `currentUserNotificationSettings` with the new `UIUserNotificationSettings`.
        case replace
    }
    
	public static let isMutuallyExclusive = false
    
    let options: UNAuthorizationOptions
    let behavior: Behavior
    
    /**
        The designated initializer.
        
        - parameter options: The `UNAuthorizationOptions` you wish to be
            registered.

        - parameter behavior: The way in which the `options` should be applied
            to the `application`. By default, this value is `.Merge`, which means
            that the `options` will be combined with the existing settings on the
            `application`. You may also specify `.Replace`, which means the `options`
            will overwrite the exisiting settings.
    */
    public init(options: UNAuthorizationOptions = [], behavior: Behavior = .merge) {
        self.options = options
        self.behavior = behavior
        self.dependentOperation = UNNotificationAuthorizationOperation(options: options, behavior: behavior)
    }
    
	public func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
		
		UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
			
			let result: OperationConditionResult
			
			if settings.authorizationStatus == .authorized {
				
				var current: UNAuthorizationOptions = []
				if settings.alertSetting == .enabled {
					current.insert(.alert)
				}
				if settings.badgeSetting == .enabled {
					current.insert(.badge)
				}
				
				if settings.soundSetting == .enabled {
					current.insert(.sound)
				}
				
				switch (current, self.options)  {
				case (let current, let options) where current.contains(options):
					result = .success
					
				default:
					let error = AOperationError(Error(currentOptions: current, desiredOptions: options, authorizationStatus: settings.authorizationStatus))
					
					result = .failure(error)
				}
				
			}
			else {
				let error = AOperationError(Error(currentOptions: [], desiredOptions: options, authorizationStatus: settings.authorizationStatus))
				
				result = .failure(error)
			}
			
			completion(result)

		})
			
    }
}

/**
    A private `Operation` subclass to register a `UIUserNotificationSettings`
    object with a `UIApplication`, prompting the user for permission if necessary.
*/
@available(iOS 10.0, *)
private class UNNotificationAuthorizationOperation: VoidOperation {
	
    var options: UNAuthorizationOptions
    let behavior: UNNotificationCondition.Behavior
    
    init(options: UNAuthorizationOptions = [], behavior: UNNotificationCondition.Behavior) {
        self.options = options
        self.behavior = behavior
        
        super.init()

        conditions(AlertPresentation())
    }
    
    override func execute() {
        DispatchQueue.main.async {
//            let current = self.application.currentUserNotificationSettings
			UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
				
				let optionsToAuthorize: UNAuthorizationOptions
				
				guard settings.authorizationStatus != .denied else {
					let error = AOperationError(UNNotificationCondition.Error(currentOptions: [], desiredOptions: [], authorizationStatus: settings.authorizationStatus))

					self.finish(error)
					return
				}
				
					switch self.behavior {
					case .merge:
						var currentOptions: UNAuthorizationOptions = []
						if settings.alertSetting == .enabled {
							currentOptions.insert(.alert)
						}
						if settings.badgeSetting == .enabled {
							currentOptions.insert(.badge)
						}
						if settings.alertSetting == .enabled {
							currentOptions.insert(.alert)
						}
						
						if settings.soundSetting == .enabled {
							currentOptions.insert(.sound)
						}

						optionsToAuthorize = currentOptions.merge(by: self.options)
						
					default:
						optionsToAuthorize = self.options
					}
					
					UNUserNotificationCenter.current().requestAuthorization(options: optionsToAuthorize, completionHandler: { (granted, error) in
						var operationError: AOperationError?
						
						if !granted {
							operationError = AOperationError(UNNotificationCondition.Error(currentOptions: [], desiredOptions: [], authorizationStatus: .denied))
						}
						
						if let error = error {
							operationError = AOperationError(error)

						}
						
						self.finish(operationError)
					})

				})
			
        }
    }
}
    
#endif
