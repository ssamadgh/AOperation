//
//  AppDelegate.swift
//  TweetSeeker
//
//  Created by Seyed Samad Gholamzadeh on 1/22/21.
//

import UIKit
import AOperation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		let rootVC: UIViewController
		
		if #available(iOS 14, *) {
			rootVC = SelectVersionTableViewController()
		}
		else {
			rootVC = TweetsCollectionViewController()
		}
		
		let window = UIWindow(frame: UIScreen.main.bounds)
		window.rootViewController = UINavigationController(rootViewController: rootVC)
		self.window = window
		window.makeKeyAndVisible()
		AOperation.Debugger.printOperationsState = true
		
		return true
	}


}

