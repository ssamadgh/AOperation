//
//  ServiceURL.swift
//  TweetSeeker
//
//  Created by Seyed Samad Gholamzadeh on 1/22/21.
//

import Foundation


private let kAPIKey = "7lQtfPPtDPnQADF6asjLPIP1P"
private let kAPISecret = "6RuhiXlwv3KBQZcyNE9Z0YK7gQmIk3wGb1Kxc8cW2JVSRMQJtW"
private let kPostMethod = "POST"
private let kGetMethod = "GET"
private let kContentTypeHeader = "Content-Type"
private let kAuthorizationHeaderKey = "Authorization"
private let kOAuthRootURL = "https://api.twitter.com/oauth2/token"
private let kTimelineRootURL = "https://api.twitter.com/1.1/statuses/user_timeline.json?count=30&screen_name="
private let kAuthorizationBody = "grant_type=client_credentials"
private let kAuthorizationContentType = "application/x-www-form-urlencoded;charset=UTF-8"


struct Twitter {
	
	static var authorizationURL: URL {
		URL(string: "https://api.twitter.com/oauth2/token")!
	}
	
	static var timelineRootURL: URL {
		URL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json?count=30&screen_name=")!
	}

}
