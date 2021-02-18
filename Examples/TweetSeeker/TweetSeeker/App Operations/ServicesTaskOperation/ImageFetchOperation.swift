//
//  TweetFetchOperation.swift
//  TweetSeeker
//
//  Created by Seyed Samad Gholamzadeh on 1/29/21.
//

/*
Abstract:
 Here wed defined a WrapperOperation that is wrapped a chain of two
 URLSessionDataTaskOperation and ImageGeneratorOperation.
*/


import UIKit
import AOperation


/// A wrapper operation that gets an image url and results image
class ImageFetchOperation: WrapperOperation<Void, UIImage> {
	let url: URL
	init(imageURL url: URL) {
		self.url = url
		super.init { (_) -> ResultableOperation<UIImage>? in
			return URLSessionTaskOperation.data(for: url)
				.deliver(to: ImageGeneratorOperation())
		}
	}
		
}


/// A simple operation that gets result of a URLSessionDataTaskOperation
/// and results an image from the received data or fails if received value is failure.
class ImageGeneratorOperation: ResultableOperation<UIImage>, ReceiverOperation {
	
	var receivedValue: Result<(data: Data, response: URLResponse), AOperationError>?
	
	override func execute() {
		guard let receivedValue = receivedValue else {
			finish(with: .failure(.receivedValueIsNil(in: self)))
			return
		}
		
		switch receivedValue {
		case .success(let result):
			
			if let image = UIImage(data: result.data) {
				finish(with: .success(image))
			}
			else {
				finish(with: .failure(AOperationError(Error.dataIsCorrupt)))
			}
			
		case .failure(let error):
			finish(with: .failure(error))
		}
		
		
	}
	
}

extension ImageGeneratorOperation {
	
	enum Error: LocalizedError {
		case dataIsCorrupt
	}
}
