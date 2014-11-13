//
//  AppDelegate.swift
//  Networking
//
//  Created by József Vesza on 09/11/14.
//  Copyright (c) 2014 Jozsef Vesza. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let networkHandler = NetworkHandler.sharedInstance

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    // MARK: background session handling
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        println("-- handleEventsForBackgroundURLSession --")
        let backgroundConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(identifier)
        let backgroundSession = NSURLSession(configuration: backgroundConfiguration, delegate: networkHandler, delegateQueue: nil)
        println("Rejoining session \(backgroundSession)")
        
        networkHandler.addCompletionHandler(completionHandler, identifier: identifier)
    }

}

