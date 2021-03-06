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
	var navigationController: UINavigationController!
	var sceneListingViewController: SceneListingViewController!
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		let window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window.makeKeyAndVisible()
		
		sceneListingViewController = SceneListingViewController(
			scenes: Scene.sceneIndex,
			sceneActivationHandler: { [unowned self] in self.activateScene($0) }
		)
		sceneListingViewController.title = "Prototypes"
		navigationController = UINavigationController(rootViewController: sceneListingViewController)
		navigationController.interactivePopGestureRecognizer!.enabled = false
		window.rootViewController = navigationController
		
		let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(AppDelegate.handleSwipeBackGesture(_:)))
		swipeGestureRecognizer.numberOfTouchesRequired = 3
		swipeGestureRecognizer.direction = .Right
		window.addGestureRecognizer(swipeGestureRecognizer)
		
		self.window = window
		
		return true
	}
	
	private func activateScene(scene: Scene) {
		let sceneViewController = SceneViewController(scene: scene)
		sceneViewController.backActionHandler = { self.navigateToList() }
		
		navigationController.setNavigationBarHidden(true, animated: true)
		navigationController.pushViewController(sceneViewController, animated: true)
		
		if !NSUserDefaults.standardUserDefaults().boolForKey("hasSeenNavigationWarning") {
			UIAlertView(title: "Navigation Tutorial", message: "Press the 'escape' key or swipe back with three fingers to navigate back.\n\nYou won't see this message again.", delegate: nil, cancelButtonTitle: "OK").show()
			NSUserDefaults.standardUserDefaults().setBool(true, forKey:"hasSeenNavigationWarning")
		}
	}
	
	func navigateToList() {
		self.navigationController.setNavigationBarHidden(false, animated: true)
		self.navigationController.setViewControllers([sceneListingViewController], animated: true)
	}
	
	func handleSwipeBackGesture(gesture: UIGestureRecognizer!) {
		navigateToList()
	}
	
	
}

