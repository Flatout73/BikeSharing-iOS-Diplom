//
//  AppDelegate.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 14/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import UIKit
import CoreData
import Swinject
import SwinjectStoryboard
import GoogleSignIn
import FBSDKCoreKit
import SwiftyUserDefaults
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let assembler = AppDelegate.createAssembler()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GIDSignIn.sharedInstance().clientID = "680941561279-iblnhng1op6pm79k0gk6dj6igd3eu7ch.apps.googleusercontent.com"
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
        
        if Defaults[.userId] == nil {
            DispatchQueue.main.async {
                self.window?.rootViewController?.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        
        if !handled {
            handled = FBSDKApplicationDelegate.sharedInstance()?.application(app, open: url, options: options) ?? false
        }
        
        return handled
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }

}


extension AppDelegate {
    fileprivate static func createAssembler() -> Assembler {
        let assemblies: [Assembly] = [BikeMapAssembly(), RidesAssembly()]
        return Assembler(assemblies, container: SwinjectStoryboard.defaultContainer)
    }
}

extension DefaultsKeys {
    static let userId = DefaultsKey<Int?>("userId")
}
