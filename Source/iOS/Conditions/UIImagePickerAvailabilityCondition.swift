//
//  UIImagePickerAvailablityCondition.swift
//  ESL
//
//  Created by Seyed Samad Gholamzadeh on 8/16/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import UIKit

public struct UIImagePickerAvailabilityCondition: OperationCondition {
    
    public static var name: String = "UIImagePickerAvailablity"
    
    public static var isMutuallyExclusive: Bool = true
    
    private let sourceType: UIImagePickerController.SourceType
    private let mediaTypes: Set<String>
    
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
            let error = NSError(code: .conditionFailed, userInfo: [OperationConditionKey : type(of: self).name, "mediaTypes" : self.mediaTypes])
            completion(.failed(error))
        }
        
    }
    
    
}
