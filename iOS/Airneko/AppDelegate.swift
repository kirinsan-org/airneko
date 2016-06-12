//
//  AppDelegate.swift
//  Airneko
//
//  Created by Jun Tanaka on 6/11/16.
//  Copyright © 2016 eje Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		registerForPushNotifications(application)

		FIRApp.configure()

		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window?.rootViewController = ViewController(nibName: nil, bundle: nil)
		window?.makeKeyAndVisible()

		return true
	}
	

	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
		// If you are receiving a notification message while your app is in the background,
		// this callback will not be fired till the user taps on the notification launching the application.
		// TODO: Handle data of notification

		// play nyaa sound in payload
		NyaaPlayer.sharedInstance.play(notificationPayload: userInfo)

		// Print full message
		print("%@", userInfo)

		completionHandler(.NoData)
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
		if notificationSettings.types != .None {
			application.registerForRemoteNotifications()
		}
	}

	func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
		var tokenString = ""

		for i in 0..<deviceToken.length {
			tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
		}

		let instanceID = FIRInstanceID.instanceID()
		instanceID.setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Unknown)

		// store Firebase instance token to database
		if let token = instanceID.token() {
			let ref = FIRDatabase.database().referenceWithPath("family/sample/token/\(token)")
			ref.setValue(true)
		}
	}
}

extension AppDelegate {
	func registerForPushNotifications(application: UIApplication) {
		let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
		application.registerUserNotificationSettings(notificationSettings)
	}
}
