//
//  TweetFetcher.swift
//  TweetSeeker
//
//  Created by Seyed Samad Gholamzadeh on 1/29/21.
//

/*
Abstract:
A helper tool used to loading and catching images for given image url.
*/


import UIKit
import AOperation

class ImageLoader {
	// MARK: Types
	
	public static let publicLoader = ImageLoader()
	
	/// A serial `OperationQueue` to lock access to the `fetchQueue` and `completionHandlers` properties.
	private let serialAccessQueue = AOperationQueue()
	
	/// An `OperationQueue` that contains `ImageFetchOperation`s for requested data.
	private let fetchQueue = AOperationQueue()
	
	/// A dictionary of dictionaries of indexpath and their closures to call when an image has been fetched for a given url.
	private var completionHandlers = [URL: [IndexPath : ((URL, IndexPath, UIImage?) -> Swift.Void)]]()
	
	/// An `NSCache` used to store fetched images.
	private var cache = NSCache<NSURL, UIImage>()
	
	// MARK: Initialization
	
	init() {
		serialAccessQueue.maxConcurrentOperationCount = 1
	}
	
	// MARK: Object fetching
	
	/**
	Asynchronously fetches data for a specified `URL`.
	
	- Parameters:
	- url: The `URL` to fetch image for.
	- completion: An optional called when the data has been fetched.
	*/
	func load(_ url: URL, for path: IndexPath, completion: ((URL, IndexPath, UIImage?) -> Swift.Void)? = nil) {
			
		// Use the serial queue while we access the fetch queue and completion handlers.
		serialAccessQueue.addOperation {
			// If a completion block has been provided, store it.
			if let completion = completion {
				var handlers = self.completionHandlers[url, default: [:]]
				handlers[path] = completion
				self.completionHandlers[url] = handlers
			}
						
			self.fetchData(for: url)
		}
	}
	
	/**
	Returns the previously fetched image for a specified `URL`.
	
	- Parameter url: The `URL` of the object to return.
	- Returns: The 'UIImage' that has previously been fetched or nil.
	*/
	func image(for url: URL) -> UIImage? {
		return cache.object(forKey: url as NSURL)
	}
	
	/**
	Cancels any enqueued image fetches for a specified `URL`. Completion
	handlers are not called if a fetch is canceled.
	
	- Parameter url: The `URL` to cancel fetches for.
	*/
	func cancelFetch(_ url: URL) {
		serialAccessQueue.addOperation {
			self.fetchQueue.isSuspended = true
			defer {
				self.fetchQueue.isSuspended = false
			}
			
			self.operation(for: url)?.cancel()
			self.completionHandlers[url] = nil
		}
	}
	
	// MARK: Convenience
	
	/**
	Begins fetching data for the provided `url` invoking the associated
	completion handler when complete.
	
	- Parameter url: The `UUID` to fetch data for.
	*/
	private func fetchData(for url: URL) {
		// If a request has already been made for the image, do nothing more.
		guard operation(for: url) == nil else { return }
		
		if let image = image(for: url) {
			// The image has already been cached; call the completion handler with that image.
			invokeCompletionHandlers(for: url, with: image)
		} else {
			// Enqueue a request for the image.
			let operation = ImageFetchOperation(imageURL: url as URL)
			
			// Set the operation's completion block to cache the fetched image and call the associated completion blocks.
			operation.didFinish { [weak self] (result) in
				guard let `self` = self else { return }
				let fetchedImage: UIImage?
				switch result {
				case .success(let image):
					self.cache.setObject(image, forKey: url as NSURL)
					fetchedImage = image
				default:
					fetchedImage = nil
				}
				
				self.serialAccessQueue.addOperation { [weak self] in
					guard let `self` = self else { return }
					self.invokeCompletionHandlers(for: url, with: fetchedImage)
				}

				
			}
			.add(to: fetchQueue)

		}
	}
	
	/**
	Returns any enqueued `ImageFetchOperation` for a specified `URL`.
	
	- Parameter url: The `URL` of the operation to return.
	- Returns: The enqueued `ImageFetchOperation` or nil.
	*/
	private func operation(for url: URL) -> ImageFetchOperation? {
		for case let fetchOperation as ImageFetchOperation in fetchQueue.operations
		where !fetchOperation.isCancelled && (fetchOperation.url as URL) == url {
			return fetchOperation
		}
		
		return nil
	}
	
	/**
	Invokes any completion handlers for a specified `URL`. Once called,
	the stored dictionary of completion handlers for the `URL` is cleared.
	
	- Parameters:
	- url: The `URL` of the completion handlers to call.
	- image: The fetched image to pass when calling a completion handler.
	*/
	private func invokeCompletionHandlers(for url: URL, with image: UIImage?) {
		let completionHandlers = self.completionHandlers[url, default: [:]]
		self.completionHandlers[url] = nil
		
		for (path, handler) in completionHandlers {
			DispatchQueue.main.async {
				handler(url, path, image)
			}
		}
	}

}
