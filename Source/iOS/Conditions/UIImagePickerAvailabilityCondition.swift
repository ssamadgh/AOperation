//
//  UIImagePickerAvailablityCondition.swift
//  ESL
//
//  Created by Seyed Samad Gholamzadeh on 8/16/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

extension UIImagePickerAvailabilityCondition {
    
    public struct Error: LocalizedError {
		public let sourceType: UIImagePickerController.SourceType
		public let mediaTypes: Set<String>
		
		public var errorDescription: String? {
			if mediaTypes.count > 1 {
				let mediaTypesString = mediaTypes.joined(separator: ", ")
				return "The mediaTypes \(mediaTypesString) are not available for sourceType \(sourceType)"

			}
			else {
				let mediaTypeString = mediaTypes.first ?? ""
				return "Them mediaType \(mediaTypeString) is not available for sourceType \(sourceType)"
			}
		}
    }
    
}

/// A condition for verifying [UIImagePicker](https://developer.apple.com/documentation/uikit/uiimagepickercontroller) source and media types availability on device.
public struct UIImagePickerAvailabilityCondition: AOperationCondition {
    
    public static var key: String = "UIImagePickerAvailablity"
    
    public static var isMutuallyExclusive: Bool = true
    
    public var dependentOperation: AOperation?
    
    private let sourceType: UIImagePickerController.SourceType
    private let mediaTypes: Set<String>
    
    /// Initializes `UIImagePickerAvailabilityCondition` with the given sourceType and media types
    public init(sourceType: UIImagePickerController.SourceType, mediaTypes: [String]) {
        self.sourceType = sourceType
        self.mediaTypes = Set(mediaTypes)
    }
    
    public func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
        
        let availableMediatypes = UIImagePickerController.availableMediaTypes(for: self.sourceType) ?? []
        
        let isAvailable = self.mediaTypes.isSubset(of: availableMediatypes)
        
        if isAvailable {
            completion(.success)
        }
        else {
			let notAvailableMediaTypes = self.mediaTypes.subtracting(availableMediatypes)
			let error = AOperationError(Error(sourceType: sourceType, mediaTypes: notAvailableMediaTypes))
            completion(.failure(error))
        }
        
    }
    
    
}

#endif
