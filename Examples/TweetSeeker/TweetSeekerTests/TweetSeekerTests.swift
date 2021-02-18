//
//  TweetSeekerTests.swift
//  TweetSeekerTests
//
//  Created by Seyed Samad Gholamzadeh on 1/22/21.
//

import XCTest
@testable import TweetSeeker
import AOperation

class TweetSeekerTests: XCTestCase {
	
	let queue = AOperationQueue()
	
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testUserModel() throws {
		let userJson =
		##"""
		    {
			  "protected" : false,
			  "is_translator" : false,
			  "profile_image_url" : "http:\/\/pbs.twimg.com\/profile_images\/831555646378082308\/lcpmEl-0_normal.jpg",
			  "created_at" : "Sun Feb 09 15:24:53 +0000 2014",
			  "id" : 2335271234,
			  "default_profile_image" : false,
			  "listed_count" : 1,
			  "profile_background_color" : "000000",
			  "follow_request_sent" : null,
			  "location" : "",
			  "entities" : {
				"url" : {
				  "urls" : [
					{
					  "display_url" : "medium.com\/@ssamadgh",
					  "url" : "https:\/\/t.co\/kRsUAnJJJK",
					  "indices" : [
						0,
						23
					  ],
					  "expanded_url" : "https:\/\/medium.com\/@ssamadgh"
					}
				  ]
				},
				"description" : {
				  "urls" : [

				  ]
				}
			  },
			  "url" : "https:\/\/t.co\/kRsUAnJJJK",
			  "description" : "iOS Developer",
			  "followers_count" : 42,
			  "geo_enabled" : false,
			  "lang" : null,
			  "profile_text_color" : "000000",
			  "statuses_count" : 102,
			  "following" : null,
			  "notifications" : null,
			  "profile_background_tile" : false,
			  "profile_use_background_image" : false,
			  "id_str" : "2335271234",
			  "name" : "Seyed Samad Gholamzadeh",
			  "profile_image_url_https" : "https:\/\/pbs.twimg.com\/profile_images\/831555646378082308\/lcpmEl-0_normal.jpg",
			  "profile_sidebar_fill_color" : "000000",
			  "profile_sidebar_border_color" : "000000",
			  "contributors_enabled" : false,
			  "default_profile" : false,
			  "profile_banner_url" : "https:\/\/pbs.twimg.com\/profile_banners\/2335271234\/1550475603",
			  "screen_name" : "ssamadgh",
			  "time_zone" : null,
			  "profile_background_image_url" : "http:\/\/abs.twimg.com\/images\/themes\/theme1\/bg.png",
			  "profile_background_image_url_https" : "https:\/\/abs.twimg.com\/images\/themes\/theme1\/bg.png",
			  "profile_link_color" : "0F1839",
			  "favourites_count" : 182,
			  "is_translation_enabled" : false,
			  "translator_type" : "none",
			  "utc_offset" : null,
			  "friends_count" : 371,
			  "verified" : false,
			  "has_extended_profile" : true
			}
		"""##.data(using: .utf8)!
		
		do {
			let _ = try JSONDecoder().decode(Tweet.User.self, from: userJson)
		} catch {
			XCTAssert(false,"\(error)")
		}
		
	}
	
	
	func testPhotoModel() throws {
		let photoJson =
		##"""
		{
			"id_str" : "1325523658228559874",
			"media_url_https" : "https:\/\/pbs.twimg.com\/media\/EmU0voYW8AIaOcW.jpg",
			"expanded_url" : "https:\/\/twitter.com\/mobillet_ir\/status\/1325523660510277632\/photo\/1",
			"id" : 1325523658228559874,
			"sizes" : {
			  "large" : {
				"w" : 936,
				"h" : 578,
				"resize" : "fit"
			  },
			  "medium" : {
				"w" : 936,
				"h" : 578,
				"resize" : "fit"
			  },
			  "thumb" : {
				"w" : 150,
				"h" : 150,
				"resize" : "crop"
			  },
			  "small" : {
				"w" : 680,
				"h" : 420,
				"resize" : "fit"
			  }
			},
			"display_url" : "pic.twitter.com\/xAfgaDsIuQ",
			"type" : "photo",
			"indices" : [
			  32,
			  55
			],
			"media_url" : "http:\/\/pbs.twimg.com\/media\/EmU0voYW8AIaOcW.jpg",
			"url" : "https:\/\/t.co\/xAfgaDsIuQ"
		  }
		"""##.data(using: .utf8)!
		
		do {
			let _ = try JSONDecoder().decode(Tweet.Photo.self, from: photoJson)
		} catch {
			XCTAssert(false,"\(error)")
		}
		
	}
	
	func testUserTimeline() throws {
		let expect = expectation(description: "Decode userTimeline json")
		let bundle = Bundle(for: type(of: self))
		let url = bundle.url(forResource: "UserTimeline", withExtension: "json")!
		
		ResultableServicesTaskOperation<[Tweet]>(request: URLRequest(url: url)).didFinish { (result) in
			XCTAssertNil(result.error, "\(result.error!.publishedError)")
			expect.fulfill()
		}
		.add(to: queue)
		wait(for: [expect], timeout: 100)
	}
	

}
