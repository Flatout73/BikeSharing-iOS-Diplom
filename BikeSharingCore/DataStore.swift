//
//  DataStore.swift
//  BikeSharingCore
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import CoreData

public class MyPersistentContainer: NSPersistentContainer {
    override public class func defaultDirectoryURL() -> URL {
        #if os(watchOS)
        print("Watch")
        #endif
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.hse.bikesharing")!
    }
    
    override init(name: String, managedObjectModel model: NSManagedObjectModel) {
        super.init(name: name, managedObjectModel: model)
    }
}

public class DataStore {
    
    public static var shared = DataStore()
    
    private init() { }
    
    public lazy var managedObjectModel: NSManagedObjectModel = {
        let proxyBundle = Bundle(for: type(of: self))
        
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = proxyBundle.url(forResource: "BikeSharing", withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    public lazy var persistentContainer: MyPersistentContainer = {
        
        let container = MyPersistentContainer(name: "BikeSharing", managedObjectModel: managedObjectModel)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            container.viewContext.automaticallyMergesChangesFromParent = true
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    public func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
