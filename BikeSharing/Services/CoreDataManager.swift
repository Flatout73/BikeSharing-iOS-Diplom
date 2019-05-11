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
    
    func saveOrCreateRide(by viewModel: RideViewModel) {
        DataStore.shared.persistentContainer.performBackgroundTask { context in
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
            
            if let bikeVM = viewModel.bike {
                let bike = self.saveOrCreateBike(by: bikeVM, in: context)
                ride.bike = bike
            }
        }
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
            
            return bike
       // }
    }
    
    func saveRide(viewModels: [RideViewModel]) {
        DataStore.shared.persistentContainer.performBackgroundTask { context in
            viewModels.forEach { viewModel in
                let model = Ride(context: context)
                model.serverID = viewModel.id!
                try! context.save()
            }
        }
    }
    
    func saveBike(viewModels: [BikeViewModel]) {
        DataStore.shared.persistentContainer.performBackgroundTask { context in
            viewModels.forEach { viewModel in
                let model = Bike(context: context)
                model.serverID = viewModel.id
                model.latitude = viewModel.location.latitude
                model.longitude = viewModel.location.longitude
                try! context.save()
            }
        }
    }
    
    func fetchRides() -> [Ride] {
        let fetchRequest: NSFetchRequest<Ride> = Ride.fetchRequest()
        let rides = try! DataStore.shared.persistentContainer.viewContext.fetch(fetchRequest)
        
        return rides
    }
    
    func fetchBikes() -> [Bike] {
        let fetchRequest: NSFetchRequest<Bike> = Bike.fetchRequest()
        let rides = try! DataStore.shared.persistentContainer.viewContext.fetch(fetchRequest)
        
        return rides
    }
}
