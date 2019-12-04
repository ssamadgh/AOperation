/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows an example of implementing the OperationCondition protocol.
*/

#if os(iOS)

import UserNotifications

@available(iOS 10.0, *)
extension AOperationError {
    
    public func map(to type: UNNotificationCondition.Error.Type) -> UNNotificationCondition.Error? {
        guard (self.info?[.key] as? String) == UNNotificationCondition.key,
            let currentOptions = self.info?[UNNotificationCondition.ErrorInfo.currentOptions],
        let desiredOptions = self.info?[UNNotificationCondition.ErrorInfo.desiredOptions]
            else { return nil }
        return UNNotificationCondition.Error(currentOptions: currentOptions as! UNAuthorizationOptions, desiredOptions: desiredOptions as! UNAuthorizationOptions)
    }
}

@available(iOS 10.0, *)
extension UNNotificationCondition {
	struct ErrorInfo {
		static let currentOptions = AOperationError.Info(rawValue: "CurrentUserNotificationOptions")
		static let desiredOptions = AOperationError.Info(rawValue: "DesiredUserNotificationOptions")

	}
    
   public struct Error: Swift.Error {
        let currentOptions: UNAuthorizationOptions
        let desiredOptions: UNAuthorizationOptions
    }
    
}

/**
    A condition for verifying that we can present alerts to the user via
    `UNNotification` .
*/
@available(iOS 10.0, *)
public struct UNNotificationCondition: AOperationCondition {

    public var dependentOperation: AOperation?
    
    public enum Behavior {
        /// Merge the new `UIUserNotificationSettings` with the `currentUserNotificationSettings`.
        case merge

        /// Replace the `currentUserNotificationSettings` with the new `UIUserNotificationSettings`.
        case replace
    }
    
	public static let key = "UserNotification"
    static let currentOptions = "CurrentUserNotificationOptions"
    static let desiredOptions = "DesiredUserNotificationOptions"
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
				if settings.alertSetting == .enabled {
					current.insert(.alert)
				}
				
				if settings.soundSetting == .enabled {
					current.insert(.sound)
				}
				
				switch (current, self.options)  {
				case (let current, let options) where current.contains(options):
					result = .satisfied
					
				default:
					let error = AOperationError.conditionFailed(with: [
						.key : Self.key,
						Self.ErrorInfo.currentOptions : current,
						Self.ErrorInfo.desiredOptions : self.options
					])
					
					result = .failed(error)
				}
				
			}
			else {
				let error = AOperationError.conditionFailed(with: [
					.key : Self.key,
					Self.ErrorInfo.currentOptions : [],
					Self.ErrorInfo.desiredOptions : self.options
				])

				result = .failed(error)
			}
			
			completion(result)

		})
			
    }
}

@available(iOS 10.0, *)
extension UNNotificationAuthorizationOperation {
	struct ErrorInfo {
		static let granted = AOperationError.Info(rawValue: "granted")
	}
}
/**
    A private `Operation` subclass to register a `UIUserNotificationSettings`
    object with a `UIApplication`, prompting the user for permission if necessary.
*/
@available(iOS 10.0, *)
private class UNNotificationAuthorizationOperation: AOperation {
	
    var options: UNAuthorizationOptions
    let behavior: UNNotificationCondition.Behavior
    
    init(options: UNAuthorizationOptions = [], behavior: UNNotificationCondition.Behavior) {
        self.options = options
        self.behavior = behavior
        
        super.init()

        addCondition(AlertPresentation())
    }
    
    override func execute() {
        DispatchQueue.main.async {
//            let current = self.application.currentUserNotificationSettings
			UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
				
				let optionsToAuthorize: UNAuthorizationOptions
				
				guard settings.authorizationStatus != .denied else {
					let error = AOperationError.executionFailed(with: [.reason : "UserNotification Authorization is denied", Self.ErrorInfo.granted : false])

					self.finishWithError(error)
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
							operationError = AOperationError.executionFailed(with: [.reason: error?.localizedDescription ?? "UserNotification Authorization Not Granted", Self.ErrorInfo.granted : granted])

						}
						
						if let error = error {
							operationError = AOperationError.executionFailed(with: [.reason: error.localizedDescription, .localizedDescription: error.localizedDescription, Self.ErrorInfo.granted : granted])

						}
						
						self.finishWithError(operationError)
					})

				})
			
        }
    }
}
    
#endif
