//
//  AppDelegate.swift
//  Movies
//
//  Created by Igor O on 08.09.2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NetworkMonitor.shared.start() // Start network monitoring
		return true
	}

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        let c = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
            c.delegateClass = SceneDelegate.self
            c.storyboard = nil
            return c
	}
}

