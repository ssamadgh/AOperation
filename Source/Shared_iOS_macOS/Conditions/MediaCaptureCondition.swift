//
//  MediaCaptureCondition.swift
//  BDOOD
//
//  Created by Seyed Samad Gholamzadeh on 6/25/19.
//  Copyright © 2019 PakkCharkhIranian. All rights reserved.
//

#if os(iOS) || os(macOS)

import Foundation
import AVFoundation

@available(OSX 10.14, *)
extension MediaCaptureCondition {
	
	public struct Error: LocalizedError {
		public let requestedMediaType: AVMediaType
		public let status: AVAuthorizationStatus
		
		public var errorDescription: String? {
			"User \(status) to access \(requestedMediaType)"
		}
    }
}

/// A condition for verifying and request access to media types available on device.
@available(OSX 10.14, *)
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
            completion(.success)
        }
        else {
			let error = AOperationError(Error(requestedMediaType: mediaType, status: stauts))
            completion(.failure(error))
        }
        
    }
	
}


@available(OSX 10.14, *)
private class MediaCapturePermissionOperation: VoidOperation {

    let mediaType: AVMediaType

    init(mediaType: AVMediaType) {
        self.mediaType = mediaType
    }
    
    override func execute() {
		if AVCaptureDevice.authorizationStatus(for: self.mediaType) == .notDetermined {
			AVCaptureDevice.requestAccess(for: self.mediaType) { (status) in
				self.finish()
			}
		}
		else {
			self.finish()
		}
		
    }
    
}

#endif
