//
//  RideListService.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 23/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import BikeSharingCore

protocol RideListService {
    func getAllRides() -> [Ride]
}

class ArticleListViewModel: RideListService {
    func getAllRides() -> [Ride] {
        return []
    }
    
    
    
}
