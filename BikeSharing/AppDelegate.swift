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
import FacebookLogin
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftyUserDefaults
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    
    let assembler = AppDelegate.createAssembler()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GIDSignIn.sharedInstance().clientID = "680941561279-iblnhng1op6pm79k0gk6dj6igd3eu7ch.apps.googleusercontent.com"
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
        
        if Defaults[.token] == nil {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
                self.window?.rootViewController = vc
                //self.window?.rootViewController?.performSegue(withIdentifier: "loginSegue", sender: nil)
            
        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarVC")
            self.window?.rootViewController = vc
            registerForPushNotifications()
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        
        if !handled {
            handled = ApplicationDelegate.shared.application(app, open: url, options: options)
        }
        
        return handled
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                granted, error in
                guard granted else { return }
                UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge]) {
                        [weak self] granted, error in
                        
                        print("Permission granted: \(granted)")
                        guard granted else { return }
                        self?.getNotificationSettings()
                }
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }

        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
//        var tokenString = “”
//
//        for i in 0..<deviceToken.length {
//            tokenString += String(format: “%02.2hhx”, arguments:[tokenChars[i]])
//        }
        
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
}


extension AppDelegate {
    fileprivate static func createAssembler() -> Assembler {
        let assemblies: [Assembly] = [BikeMapAssembly(), RidesAssembly()]
        return Assembler(assemblies, container: SwinjectStoryboard.defaultContainer)
    }
}

extension DefaultsKeys {
    static let token = DefaultsKey<String?>("token")
}

extension SwinjectStoryboard {
    @objc class func setup() {
        defaultContainer.register(CoreDataManager.self) { _ in
            return CoreDataManager()
        }
        
        defaultContainer.register(ApiService.self) { _ in
            return ApiService()
        }
        
        defaultContainer.register(MapKitManager.self) { _ in
            return MapKitManager()
        }
        
        let bluetoothManager = BluetoothManager()
        defaultContainer.register(BluetoothManager.self) { _ in
            return bluetoothManager
        }
        
        defaultContainer.register(AccountService.self) { resolver in
            return AccountService(coreDataManager: resolver.resolve(CoreDataManager.self)!)
        }
        
        defaultContainer.storyboardInitCompleted(RidingViewController.self) { resolver, controller in
            controller.coreDataManager = resolver.resolve(CoreDataManager.self)
            controller.apiService = resolver.resolve(ApiService.self)
            controller.mapkitManager = resolver.resolve(MapKitManager.self)
            controller.bluetoothManager = resolver.resolve(BluetoothManager.self)
        }
        
        defaultContainer.storyboardInitCompleted(ScannerViewController.self) { resolver, controller in
            controller.apiService = resolver.resolve(ApiService.self)
            controller.coreDataManager = resolver.resolve(CoreDataManager.self)
            controller.mapkitManager = resolver.resolve(MapKitManager.self)
            controller.bluetoothManager = resolver.resolve(BluetoothManager.self)
        }
        
        defaultContainer.storyboardInitCompleted(LoginViewController.self) { resolver, controller in
            controller.apiService = resolver.resolve(ApiService.self)
            controller.coreDataManager = resolver.resolve(CoreDataManager.self)
        }
        
        defaultContainer.storyboardInitCompleted(AccountTableViewController.self) { resolver, controller in
            controller.service = resolver.resolve(AccountService.self)
        }
        
        defaultContainer.storyboardInitCompleted(FeedbackViewController.self) { resolver, controller in
            controller.apiService = resolver.resolve(ApiService.self)
            controller.coreDataManager = resolver.resolve(CoreDataManager.self)
        }
    }
}
