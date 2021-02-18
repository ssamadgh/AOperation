//
//  AppDelegate.swift
//  Earthquakes
//
//  Created by Seyed Samad Gholamzadeh on 10/5/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import AOperation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    //MARK: Properties
    
    var window: UIWindow?

    //MARK: UIApplicationDelegate
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		
		// Turn this flag on to track operations lifecycle.
		AOperation.Debugger.printOperationsState = true
		return true
	}
}


