//
//  CoreDataManager.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 23/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import CoreData
import BikeSharingCore

class CoreDataManager {
    
    func saveOneRide(by viewModel: RideViewModel) {
        DataStore.shared.persistentContainer.performBackgroundTask { context in
            self.saveOrCreateRide(by: viewModel, in: context)
            try? context.save()
        }
    }
    
    func saveOrCreateRide(by viewModel: RideViewModel, in context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Ride> = Ride.fetchRequest()
        let id = viewModel.id!
        fetchRequest.predicate = NSPredicate(format: "serverID == %ld", id)
        let ride: Ride
        if let saved = try? context.fetch(fetchRequest).first {
            ride = saved
        } else {
            ride = Ride(context: context)
        }
        ride.serverID = viewModel.id!
        ride.cost = viewModel.cost ?? 0
        ride.endDate = viewModel.endTime as Date?
        ride.startDate = viewModel.startTime
        ride.startLatitude = viewModel.startLocation.latitude
        ride.startLongitude = viewModel.startLocation.longitude
        ride.endLatitude = viewModel.endLocation?.latitude ?? viewModel.startLocation.latitude
        ride.endLongitude = viewModel.endLocation?.longitude ?? viewModel.startLocation.longitude
        ride.imageURL = viewModel.imageURL
        ride.startAddress = viewModel.startAddress
        ride.endAddress = viewModel.endAddress
        
        if let locations = viewModel.locations {
            for l in locations {
                let loc = Location(context: context)
                loc.latitude = l.latitude
                loc.longitude = l.longitude
                loc.ride = ride
            }
        }
        
        if let bikeVM = viewModel.bike {
            let bike = self.saveOrCreateBike(by: bikeVM, in: context)
            ride.bike = bike
        } else {
            print("kek")
        }
        
        if let transcation = viewModel.transaction {
            let trans = saveOrCreateTransaction(by: transcation, in: context)
            ride.transaction = trans
        }
    }
    
    func saveOrCreateTransaction(by viewModel: TransactionViewModel, in context: NSManagedObjectContext) -> Transaction {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "token == %ld", viewModel.token)
        let transaction: Transaction
        if let saved = try? context.fetch(fetchRequest).first {
            transaction = saved
        } else {
            transaction = Transaction(context: context)
        }
        if let id = viewModel.id {
            transaction.serverID = id
        }
        transaction.cost = viewModel.cost ?? 0
        transaction.desc = viewModel.description
        transaction.token = viewModel.token
        transaction.currency = viewModel.currency
        
        return transaction
    }
    
    func saveOrCreateBike(by viewModel: BikeViewModel, in context: NSManagedObjectContext) -> Bike {
        //DataStore.shared.persistentContainer.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<Bike> = Bike.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "serverID == %ld", viewModel.id)
            let bike: Bike
            if let saved = try? context.fetch(fetchRequest).first {
                bike = saved
            } else {
                bike = Bike(context: context)
            }
            bike.serverID = viewModel.id
            bike.latitude = viewModel.location.latitude
            bike.longitude = viewModel.location.longitude
            bike.name = viewModel.name
            bike.address = viewModel.address
        
            return bike
       // }
    }
    
    @discardableResult
    func saveOrCreateEntity<T: BSModelProtocol>(by viewModel: T, in context: NSManagedObjectContext) -> T.CoreDataType {
        let fetchRequest: NSFetchRequest<T.CoreDataType> = T.CoreDataType.fetchRequest() as! NSFetchRequest<T.CoreDataType>
        fetchRequest.predicate = NSPredicate(format: "serverID == %ld", viewModel.id)
        let entity: T.CoreDataType
        if let saved = try? context.fetch(fetchRequest).first {
            entity = saved
        } else {
            entity = T.CoreDataType(context: context)
        }

        viewModel.saveModel(for: entity)
        
        return entity
    }
    
    func saveModel<T: BSModelProtocol>(viewModel: T) {
        DataStore.shared.persistentContainer.performBackgroundTask { context in
            self.saveOrCreateEntity(by: viewModel, in: context)
            
            try! context.save()
        }
    }
    
    func fetchEntity<T: NSManagedObject>() -> T? {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        let entity = try! DataStore.shared.persistentContainer.viewContext.fetch(fetchRequest).first
        
        return entity
    }
    
    func saveRide(viewModels: [RideViewModel]) {
        DataStore.shared.persistentContainer.performBackgroundTask { context in
            for viewModel in viewModels {
                self.saveOrCreateRide(by: viewModel, in: context)
            }
            
            try! context.save()
            
        }
    }
    
    func saveBike(viewModels: [BikeViewModel]) {
        DataStore.shared.persistentContainer.performBackgroundTask { context in
            viewModels.forEach { viewModel in
                self.saveOrCreateBike(by: viewModel, in: context)
            }
        }
    }
    
    
    func fetchRides() -> [Ride] {
        let fetchRequest: NSFetchRequest<Ride> = Ride.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        let rides = try! DataStore.shared.persistentContainer.viewContext.fetch(fetchRequest)
        
        return rides
    }
    
    func fetchBikes() -> [Bike] {
        let fetchRequest: NSFetchRequest<Bike> = Bike.fetchRequest()
        let rides = try! DataStore.shared.persistentContainer.viewContext.fetch(fetchRequest)
        
        return rides
    }
    
    func destroyDatabase() {
        guard let url = DataStore.shared.persistentContainer.persistentStoreCoordinator.persistentStores.first?.url else {
            return
        }
        try! DataStore.shared.persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
    }
    
    func findUnfinishedRide() -> [Ride] {
        let fetchRequest: NSFetchRequest<Ride> = Ride.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "endDate == NULL", argumentArray: nil)
        
        let rides = try! DataStore.shared.persistentContainer.viewContext.fetch(fetchRequest)
        
        return rides
    }
}
