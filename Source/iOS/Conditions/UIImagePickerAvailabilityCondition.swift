//
//  UIImagePickerAvailablityCondition.swift
//  ESL
//
//  Created by Seyed Samad Gholamzadeh on 8/16/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import UIKit

extension AOperationError {
    public func map(to type: UIImagePickerAvailabilityCondition.Error.Type) -> UIImagePickerAvailabilityCondition.Error? {
        guard (self.info?[.key] as? String) == UIImagePickerAvailabilityCondition.key,
            let mediaTypes = self.info?[UIImagePickerAvailabilityCondition.ErrorInfo.notAvailableMediaTypes] else { return nil }
        return UIImagePickerAvailabilityCondition.Error(notAvailableMediaTypes: mediaTypes as! [String])
    }
    
}

extension UIImagePickerAvailabilityCondition {
	struct ErrorInfo {
		static let notAvailableMediaTypes = AOperationError.Info(rawValue: "mediaTypes")
	}
    
    public struct Error: Swift.Error {
        let notAvailableMediaTypes: [String]
    }
    
}

/// A condition for verifying UIImagePicker source and media types availability on device.
public struct UIImagePickerAvailabilityCondition: AOperationCondition {
    
    public static var key: String = "UIImagePickerAvailablity"
    
    public static var isMutuallyExclusive: Bool = true
    
    private let sourceType: UIImagePickerController.SourceType
    private let mediaTypes: Set<String>
    
    /// Initializes `UIImagePickerAvailabilityCondition` with the given sourceType and media types
    public init(sourceType: UIImagePickerController.SourceType, mediaTypes: [String]) {
        self.sourceType = sourceType
        self.mediaTypes = Set(mediaTypes)
    }
    
    public func dependencyForOperation(_ operation: AOperation) -> Operation? {
        return nil
    }
    
    public func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
        
        let availableMediatypes = UIImagePickerController.availableMediaTypes(for: self.sourceType) ?? []
        
        let isAvailable = self.mediaTypes.isSubset(of: availableMediatypes)
        
        if isAvailable {
            completion(.satisfied)
        }
        else {
			let info: [AOperationError.Info : Any?] =
			[
				.key : type(of: self).key,
				type(of: self).ErrorInfo.notAvailableMediaTypes : Array(self.mediaTypes)
			]
			let error = AOperationError.conditionFailed(with: info)
            completion(.failed(error))
        }
        
    }
    
    
}
