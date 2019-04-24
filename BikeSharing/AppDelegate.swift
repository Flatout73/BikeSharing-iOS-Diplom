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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    let serverURL = "http://localhost:8443"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        GIDSignIn.sharedInstance().clientID = "680941561279-iblnhng1op6pm79k0gk6dj6igd3eu7ch.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        
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

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            
            
            var urlRequest = URLRequest(url: URL(string: serverURL + "/tokensignin")!)
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = idToken?.data(using: .utf8)
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let data = data {
                    let user = try! JSONDecoder().decode(UserViewModel.self, from: data)
                    UserDefaults.standard.set(user.id, forKey: "userId")
                    
                }
            }.resume()
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }

}


extension AppDelegate {
    fileprivate static func createAssembler() -> Assembler {
        let assemblies: [Assembly] = []
        return Assembler(assemblies, container: SwinjectStoryboard.defaultContainer)
    }
}

extension DefaultsKeys {
    static let userId = DefaultsKey<Int?>("userId")
}
