//
//  AppDelegate.swift
//  pong_
//
//  Created by Elie Bengou on 12/02/2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
     var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: HomeViewController())
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
