//
//  RideListRouter.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import BikeSharingCore

protocol RideListRouter {
    func showRideInfo(with ride: Ride)
}

class BaseRideListRouter: Router {
    
}
