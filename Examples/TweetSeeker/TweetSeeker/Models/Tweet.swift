//
//  Tweet.swift
//  TweetSeeker
//
//  Created by Seyed Samad Gholamzadeh on 1/22/21.
//

import Foundation
import UIKit

/// a Model to decode received  json data
public class Tweet: Decodable, Hashable {

	public let id: Int
	public let text: String
	public let user: User
	public let photo: Photo?
	public let source: String
	
	enum CodingKeys: String, CodingKey {
		case id = "id"
		case text
		case user
		case entities
		case source
	}
	
	enum EntitiesCodingKeys: String, CodingKey {
		case photo = "media"
	}
	
	required public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		let id = try container.decode(Int.self, forKey: .id)
		let text = try container.decode(String.self, forKey: .text)
		let user = try container.decode(User.self, forKey: .user)
		let source = try container.decode(String.self, forKey: .source)

		self.id = id
		self.text = text
		self.user = user
		self.source = source
		
		let childContainer = try container.nestedContainer(keyedBy: EntitiesCodingKeys.self, forKey: .entities)
		let photos = try? childContainer.decodeIfPresent([Photo].self, forKey: .photo)
		self.photo = photos?.first(where: {$0.type == "photo" && $0.originalURL != nil})
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	public static func == (lhs: Tweet, rhs: Tweet) -> Bool {
		lhs.id == rhs.id
	}

}

extension Tweet {
	
	public struct User: Decodable {
		let id: Int
		let name: String
		let screenName: String
		let description: String
		let profileBackgroundColor: String
		let profileBackgroundImageUrl: URL?
		let profileImageUrl: URL?
		let profileLinkColor: String
		
		
		enum CodingKeys: String, CodingKey {
			case id
			case name
			case screenName = "screen_name"
			case description
			case profileBackgroundColor = "profile_background_color"
			case profileBackgroundImageUrl = "profile_background_image_url_https"
			case profileImageUrl = "profile_image_url_https"
			case profileLinkColor = "profile_link_color"
		}

	}
	
	public class Photo: Decodable {
		let id: Int
		let originalURL: URL?
		let type: String
		
		var thumb: URL? {
			guard let url = originalURL else { return nil }
			var comp = URLComponents(string: url.absoluteString)!
			comp.queryItems = [URLQueryItem(name: "name", value: "thumb")]
			return comp.url
		}
		
		var small: URL? {
			guard let url = originalURL else { return nil }
			var comp = URLComponents(string: url.absoluteString)!
			comp.queryItems = [URLQueryItem(name: "name", value: "small")]
			return comp.url
		}
		
		var medium: URL? {
			guard let url = originalURL else { return nil }
			var comp = URLComponents(string: url.absoluteString)!
			comp.queryItems = [URLQueryItem(name: "name", value: "medium")]
			return comp.url
		}
		
		var large: URL? {
			guard let url = originalURL else { return nil }
			var comp = URLComponents(string: url.absoluteString)!
			comp.queryItems = [URLQueryItem(name: "name", value: "large")]
			return comp.url
		}
		
		enum CodingKeys: String, CodingKey {
			case id
			case type
			case originalURL = "media_url_https"
		}
		
	}
		
}




/*
User
{\"id\":2335271234,\"id_str\":\"2335271234\",\"name\":\"Seyed Samad Gholamzadeh\",\"screen_name\":\"ssamadgh\",\"location\":\"\",\"description\":\"iOS Developer\",\"url\":\"https:\\/\\/t.co\\/kRsUAnJJJK\",\"entities\":{\"url\":{\"urls\":[{\"url\":\"https:\\/\\/t.co\\/kRsUAnJJJK\",\"expanded_url\":\"https:\\/\\/medium.com\\/@ssamadgh\",\"display_url\":\"medium.com\\/@ssamadgh\",\"indices\":[0,23]}]},\"description\":{\"urls\":[]}},\"protected\":false,\"followers_count\":42,\"friends_count\":370,\"listed_count\":1,\"created_at\":\"Sun Feb 09 15:24:53 +0000 2014\",\"favourites_count\":182,\"utc_offset\":null,\"time_zone\":null,\"geo_enabled\":false,\"verified\":false,\"statuses_count\":102,\"lang\":null,\"contributors_enabled\":false,\"is_translator\":false,\"is_translation_enabled\":false,\"profile_background_color\":\"000000\",\"profile_background_image_url\":\"http:\\/\\/abs.twimg.com\\/images\\/themes\\/theme1\\/bg.png\",\"profile_background_image_url_https\":\"https:\\/\\/abs.twimg.com\\/images\\/themes\\/theme1\\/bg.png\",\"profile_background_tile\":false,\"profile_image_url\":\"http:\\/\\/pbs.twimg.com\\/profile_images\\/831555646378082308\\/lcpmEl-0_normal.jpg\",\"profile_image_url_https\":\"https:\\/\\/pbs.twimg.com\\/profile_images\\/831555646378082308\\/lcpmEl-0_normal.jpg\",\"profile_banner_url\":\"https:\\/\\/pbs.twimg.com\\/profile_banners\\/2335271234\\/1550475603\",\"profile_link_color\":\"0F1839\",\"profile_sidebar_border_color\":\"000000\",\"profile_sidebar_fill_color\":\"000000\",\"profile_text_color\":\"000000\",\"profile_use_background_image\":false,\"has_extended_profile\":true,\"default_profile\":false,\"default_profile_image\":false,\"following\":null,\"follow_request_sent\":null,\"notifications\":null,\"translator_type\":\"none\"}
*/

/*
//Media

{\"id\":1325523658228559874,\"id_str\":\"1325523658228559874\",\"indices\":[49,72],\"media_url\":\"http:\\/\\/pbs.twimg.com\\/media\\/EmU0voYW8AIaOcW.jpg\",\"media_url_https\":\"https:\\/\\/pbs.twimg.com\\/media\\/EmU0voYW8AIaOcW.jpg\",\"url\":\"https:\\/\\/t.co\\/xAfgaDsIuQ\",\"display_url\":\"pic.twitter.com\\/xAfgaDsIuQ\",\"expanded_url\":\"https:\\/\\/twitter.com\\/mobillet_ir\\/status\\/1325523660510277632\\/photo\\/1\",\"type\":\"photo\",\"sizes\":{\"thumb\":{\"w\":150,\"h\":150,\"resize\":\"crop\"},\"small\":{\"w\":680,\"h\":420,\"resize\":\"fit\"},\"medium\":{\"w\":936,\"h\":578,\"resize\":\"fit\"},\"large\":{\"w\":936,\"h\":578,\"resize\":\"fit\"}},\"source_status_id\":1325523660510277632,\"source_status_id_str\":\"1325523660510277632\",\"source_user_id\":938873920622653440,\"source_user_id_str\":\"938873920622653440\"}
*/



/*
{\"created_at\":\"Fri Dec 18 09:54:57 +0000 2020\",\"id\":1339871766634786816,\"id_str\":\"1339871766634786816\",\"text\":\"RT @Pargol68: \\u062f\\u0648\\u0633\\u062a\\u0627\\u0646 \\u062a\\u06cc\\u0645 \\u0645\\u0627 \\u0628\\u0647 \\u062f\\u0646\\u0628\\u0627\\u0644 #SenioriOSDevelopr \\u0647\\u0633\\u062a.\\n\\u062e\\u0648\\u0634\\u062d\\u0627\\u0644 \\u0645\\u06cc\\u0634\\u0645 \\u0627\\u06af\\u0631 \\u062f\\u0631 \\u0627\\u06cc\\u0646 \\u062d\\u0648\\u0632\\u0647 \\u0641\\u0639\\u0627\\u0644\\u06cc\\u062a \\u0645\\u06cc\\u06a9\\u0646\\u06cc\\u0646 \\u0631\\u0632\\u0648\\u0645\\u062a\\u0648\\u0646 \\u0631\\u0648 \\u0628\\u0647 \\u0627\\u06cc\\u0645\\u06cc\\u0644 hr@mobillet.ir \\u0627\\u2026\",\"truncated\":false,\"entities\":{\"hashtags\":[{\"text\":\"SenioriOSDevelopr\",\"indices\":[37,55]}],\"symbols\":[],\"user_mentions\":[{\"screen_name\":\"Pargol68\",\"name\":\"Golgoli\",\"id\":1130353358945042432,\"id_str\":\"1130353358945042432\",\"indices\":[3,12]}],\"urls\":[]},\"source\":\"\\u003ca href=\\\"http:\\/\\/twitter.com\\/download\\/iphone\\\" rel=\\\"nofollow\\\"\\u003eTwitter for iPhone\\u003c\\/a\\u003e\",\"in_reply_to_status_id\":null,\"in_reply_to_status_id_str\":null,\"in_reply_to_user_id\":null,\"in_reply_to_user_id_str\":null,\"in_reply_to_screen_name\":null,
	
\"user\":
{\"id\":2335271234,\"id_str\":\"2335271234\",\"name\":\"Seyed Samad Gholamzadeh\",\"screen_name\":\"ssamadgh\",\"location\":\"\",\"description\":\"iOS Developer\",\"url\":\"https:\\/\\/t.co\\/kRsUAnJJJK\",\"entities\":{\"url\":{\"urls\":[{\"url\":\"https:\\/\\/t.co\\/kRsUAnJJJK\",\"expanded_url\":\"https:\\/\\/medium.com\\/@ssamadgh\",\"display_url\":\"medium.com\\/@ssamadgh\",\"indices\":[0,23]}]},\"description\":{\"urls\":[]}},\"protected\":false,\"followers_count\":42,\"friends_count\":370,\"listed_count\":1,\"created_at\":\"Sun Feb 09 15:24:53 +0000 2014\",\"favourites_count\":182,\"utc_offset\":null,\"time_zone\":null,\"geo_enabled\":false,\"verified\":false,\"statuses_count\":102,\"lang\":null,\"contributors_enabled\":false,\"is_translator\":false,\"is_translation_enabled\":false,\"profile_background_color\":\"000000\",\"profile_background_image_url\":\"http:\\/\\/abs.twimg.com\\/images\\/themes\\/theme1\\/bg.png\",\"profile_background_image_url_https\":\"https:\\/\\/abs.twimg.com\\/images\\/themes\\/theme1\\/bg.png\",\"profile_background_tile\":false,\"profile_image_url\":\"http:\\/\\/pbs.twimg.com\\/profile_images\\/831555646378082308\\/lcpmEl-0_normal.jpg\",\"profile_image_url_https\":\"https:\\/\\/pbs.twimg.com\\/profile_images\\/831555646378082308\\/lcpmEl-0_normal.jpg\",\"profile_banner_url\":\"https:\\/\\/pbs.twimg.com\\/profile_banners\\/2335271234\\/1550475603\",\"profile_link_color\":\"0F1839\",\"profile_sidebar_border_color\":\"000000\",\"profile_sidebar_fill_color\":\"000000\",\"profile_text_color\":\"000000\",\"profile_use_background_image\":false,\"has_extended_profile\":true,\"default_profile\":false,\"default_profile_image\":false,\"following\":null,\"follow_request_sent\":null,\"notifications\":null,\"translator_type\":\"none\"}

	,\"geo\":null,\"coordinates\":null,\"place\":null,\"contributors\":null,\"retweeted_status\":{\"created_at\":\"Thu Dec 17 18:50:31 +0000 2020\",\"id\":1339644157032357891,\"id_str\":\"1339644157032357891\",\"text\":\"\\u062f\\u0648\\u0633\\u062a\\u0627\\u0646 \\u062a\\u06cc\\u0645 \\u0645\\u0627 \\u0628\\u0647 \\u062f\\u0646\\u0628\\u0627\\u0644 #SenioriOSDevelopr \\u0647\\u0633\\u062a.\\n\\u062e\\u0648\\u0634\\u062d\\u0627\\u0644 \\u0645\\u06cc\\u0634\\u0645 \\u0627\\u06af\\u0631 \\u062f\\u0631 \\u0627\\u06cc\\u0646 \\u062d\\u0648\\u0632\\u0647 \\u0641\\u0639\\u0627\\u0644\\u06cc\\u062a \\u0645\\u06cc\\u06a9\\u0646\\u06cc\\u0646 \\u0631\\u0632\\u0648\\u0645\\u062a\\u0648\\u0646 \\u0631\\u0648 \\u0628\\u0647 \\u0627\\u06cc\\u0645\\u06cc\\u0644 hr@mob\\u2026 https:\\/\\/t.co\\/Pxl11V2JmT\",\"truncated\":true,\"entities\":{\"hashtags\":[{\"text\":\"SenioriOSDevelopr\",\"indices\":[23,41]}],\"symbols\":[],\"user_mentions\":[],\"urls\":[{\"url\":\"https:\\/\\/t.co\\/Pxl11V2JmT\",\"expanded_url\":\"https:\\/\\/twitter.com\\/i\\/web\\/status\\/1339644157032357891\",\"display_url\":\"twitter.com\\/i\\/web\\/status\\/1\\u2026\",\"indices\":[117,140]}]},\"source\":\"\\u003ca href=\\\"http:\\/\\/twitter.com\\/download\\/iphone\\\" rel=\\\"nofollow\\\"\\u003eTwitter for iPhone\\u003c\\/a\\u003e\",\"in_reply_to_status_id\":null,\"in_reply_to_status_id_str\":null,\"in_reply_to_user_id\":null,\"in_reply_to_user_id_str\":null,\"in_reply_to_screen_name\":null,\"user\":{\"id\":1130353358945042432,\"id_str\":\"1130353358945042432\",\"name\":\"Golgoli\",\"screen_name\":\"Pargol68\",\"location\":\"\",\"description\":\"HR Manager\",\"url\":null,\"entities\":{\"description\":{\"urls\":[]}},\"protected\":false,\"followers_count\":167,\"friends_count\":190,\"listed_count\":0,\"created_at\":\"Mon May 20 06:03:36 +0000 2019\",\"favourites_count\":1913,\"utc_offset\":null,\"time_zone\":null,\"geo_enabled\":true,\"verified\":false,\"statuses_count\":469,\"lang\":null,\"contributors_enabled\":false,\"is_translator\":false,\"is_translation_enabled\":false,\"profile_background_color\":\"F5F8FA\",\"profile_background_image_url\":null,\"profile_background_image_url_https\":null,\"profile_background_tile\":false,\"profile_image_url\":\"http:\\/\\/pbs.twimg.com\\/profile_images\\/1220085295795843075\\/YLGwT6Q3_normal.jpg\",\"profile_image_url_https\":\"https:\\/\\/pbs.twimg.com\\/profile_images\\/1220085295795843075\\/YLGwT6Q3_normal.jpg\",\"profile_banner_url\":\"https:\\/\\/pbs.twimg.com\\/profile_banners\\/1130353358945042432\\/1579725978\",\"profile_link_color\":\"1DA1F2\",\"profile_sidebar_border_color\":\"C0DEED\",\"profile_sidebar_fill_color\":\"DDEEF6\",\"profile_text_color\":\"333333\",\"profile_use_background_image\":true,\"has_extended_profile\":true,\"default_profile\":true,\"default_profile_image\":false,\"following\":null,\"follow_request_sent\":null,\"notifications\":null,\"translator_type\":\"none\"},\"geo\":null,\"coordinates\":null,\"place\":null,\"contributors\":null,\"is_quote_status\":false,\"retweet_count\":17,\"favorite_count\":20,\"favorited\":false,\"retweeted\":false,\"possibly_sensitive\":true,\"lang\":\"fa\"},\"is_quote_status\":false,\"retweet_count\":17,\"favorite_count\":0,\"favorited\":false,\"retweeted\":false,\"lang\":\"fa\"}
*/



