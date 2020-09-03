//
//  AppDelegate.swift
//  LiveParking
//
//  Created by touch keang david on 9/2/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        LocationService.shared.start()
        return true
    }

}

