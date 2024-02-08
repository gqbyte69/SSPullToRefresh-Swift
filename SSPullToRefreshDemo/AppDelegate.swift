//
//  AppDelegate.swift
//  SSPullToRefreshDemo
//
//  Created by Adonis Dumadapat on 1/30/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)

        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(identifier: "ViewController")

        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        return true
    }
}

