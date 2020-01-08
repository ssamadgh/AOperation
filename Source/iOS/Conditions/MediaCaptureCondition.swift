//
//  MediaCaptureCondition.swift
//  BDOOD
//
//  Created by Seyed Samad Gholamzadeh on 6/25/19.
//  Copyright © 2019 PakkCharkhIranian. All rights reserved.
//

import Foundation
import AVFoundation

extension AOperationError {
    public func map(to type: MediaCaptureCondition.Error.Type) -> MediaCaptureCondition.Error? {
        guard (self.info?[.key] as? String) == MediaCaptureCondition.key,
            let mediaType = self.info?[MediaCaptureCondition.ErrorInfo.notAvailableMediaType] else {
            return nil
        }
        
        return MediaCaptureCondition.Error(notAvailableMediaType: mediaType as! AVMediaType)
        
    }
}

extension MediaCaptureCondition {
    struct ErrorInfo {
        static let notAvailableMediaType = AOperationError.Info(rawValue: "mediaType")
    }
    
    public struct Error {
        let notAvailableMediaType: AVMediaType
    }
}

/// A condition for verifying media types availability on device.
public struct MediaCaptureCondition: AOperationCondition {
    
    let mediaType: AVMediaType
    
    public static var key: String = "MediaCapture"
    
    public static var isMutuallyExclusive: Bool = false
    
    public var dependentOperation: AOperation?
    
    /// Initializes `MediaCaptureCondition` with the given media type
    public init(mediaType: AVMediaType) {
        self.mediaType = mediaType
        self.dependentOperation = MediaCapturePermissionOperation(mediaType: self.mediaType)
    }
    
    public func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
        let stauts = AVCaptureDevice.authorizationStatus(for: self.mediaType)
        
        if stauts == .authorized {
            completion(.satisfied)
        }
        else {
			let error = AOperationError.conditionFailed(with: [.key : type(of: self).key])
            completion(.failed(error))
        }
        
    }
    
    
}



private class MediaCapturePermissionOperation: AOperation {

    let mediaType: AVMediaType

    init(mediaType: AVMediaType) {
        self.mediaType = mediaType
    }
    
    override func execute() {
		if AVCaptureDevice.authorizationStatus(for: self.mediaType) == .notDetermined {
			AVCaptureDevice.requestAccess(for: self.mediaType) { (status) in
				self.finishWithError(nil)
			}
		}
		else {
			self.finishWithError(nil)
		}
		
    }
    
}
