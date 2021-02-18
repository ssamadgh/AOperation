//
//  FetchUserTimeLineOperation.swift
//  TweetSeeker
//
//  Created by Seyed Samad Gholamzadeh on 1/22/21.
//

/*
Abstract:
Here a WrapperOperation defined on top of
AuthorizedResultableServicesTaskOperation
to fetch tweets from created URLRequest.
*/


import Foundation
import AOperation

/// A wrapper operation to create a URLRequest for fetching the given twitter username tweets.
class FetchUserTimeLineOperation: WrapperOperation<String, [Tweet]>, RetryableOperation {
	
	func new() -> Self {
		FetchUserTimeLineOperation() as! Self
	}
	
	init() {
		super.init { (receivedValue) -> ResultableOperation<[Tweet]>? in
			do {
				let userName = ((try receivedValue?.get()) ?? "")
					.stringByRemovingWhitespace()
				
				let url = URL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json?count=30&screen_name=\(userName)")!
				var request = URLRequest(url: url)
				request.httpMethod = URLRequest.HTTPMethod.get
				return AuthorizedResultableServicesTaskOperation(request: request)

			}
			catch {
				return nil
			}
		}
	}
}

private extension String {
	func stringByRemovingWhitespace() -> String
	{
		let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
		return trimmed.replacingOccurrences(of: " ", with: "")
	}
}
