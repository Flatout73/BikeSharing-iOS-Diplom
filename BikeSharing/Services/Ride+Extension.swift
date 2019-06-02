//
//  Ride+CoreDataProperties.swift
//  
//
//  Created by Леонид Лядвейкин on 11/05/2019.
//
//

import BikeSharingCore

extension Ride {
    var viewModel: RideViewModel {
        return RideViewModel(id: self.serverID,
                             startLocation: Point(latitude: self.startLatitude, longitude: self.startLongitude),
                             endLocation: Point(latitude: self.endLatitude, longitude: self.endLongitude),
                             startAddress: self.startAddress, endAddress: self.endAddress, startTime: self.startDate!, endTime: self.endDate, cost: self.cost, bike: nil, locations: self.locations?.array.compactMap { $0 as? Location }.map { Point(latitude: $0.latitude, longitude: $0.longitude) }, imageURL: self.imageURL)
    }
}
