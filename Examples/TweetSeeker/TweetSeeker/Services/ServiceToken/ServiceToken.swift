//
//  ServiceToken.swift
//  iOS_Exapmle
//
//  Created by Seyed Samad Gholamzadeh on 12/23/20.
//  Copyright © 2020 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

private let kAuthorizationTokenStorageKey = "authorizationToken"


struct ServiceToken {
	
	public enum State: Int {
		case available, unavailable
	}	

	private static let serialQueue = DispatchQueue(label: "ServiceToken_SerialQueue")
	
	static var authentication: String? {
		get {
			serialQueue.sync {
				UserDefaults.standard.string(forKey: kAuthorizationTokenStorageKey)
			}
		}
		
		set {
			serialQueue.async {
				if let token = newValue {
					UserDefaults.standard.set(token, forKey: kAuthorizationTokenStorageKey)
				}
				else {
					UserDefaults.standard.removeObject(forKey: kAuthorizationTokenStorageKey)
				}
			}
		}
		
	}
	
	
	static var state: State {
		
		switch authentication {
		case nil:
			return .unavailable

		default:
			
			return .available
		}

	}
	
}


