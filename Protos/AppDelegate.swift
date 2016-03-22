//
//  AppDelegate.swift
//  Protos
//
//  Created by Jason Brennan on 3/22/16.
//  Copyright © 2016 Jason Brennan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		
		let rootViewController = ViewController(nibName: nil, bundle: nil)
		window?.rootViewController = rootViewController
		
		window?.makeKeyAndVisible()
		
		return true
	}

}

