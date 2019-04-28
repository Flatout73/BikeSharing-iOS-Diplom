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
    public static let shared = CoreDataManager()
    
    func saveRide(viewModels: [RideViewModel]) {
        DataStore.shared.persistentContainer.performBackgroundTask { context in
            viewModels.forEach { viewModel in
                let model = Ride(context: context)
                model.serverId = viewModel.id
                try! context.save()
            }
        }
    }
    
    func fetchRides() -> [Ride] {
        let fetchRequest: NSFetchRequest<Ride> = Ride.fetchRequest()
        let rides = try! DataStore.shared.persistentContainer.viewContext.fetch(fetchRequest)
        
        return rides
    }
}
