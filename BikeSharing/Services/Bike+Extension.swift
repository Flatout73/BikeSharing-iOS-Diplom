//
//  Bike+CoreDataProperties.swift
//  
//
//  Created by Леонид Лядвейкин on 11/05/2019.
//
//

import BikeSharingCore

extension Bike {

    var viewModel: BikeViewModel {
        return BikeViewModel(id: self.serverID, location: Point(latitude: self.latitude, longitude: self.longitude), name: self.name, address: self.address)
    }

}
