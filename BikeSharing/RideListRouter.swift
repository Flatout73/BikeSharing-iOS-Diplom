//
//  RideListRouter.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import BikeSharingCore

protocol RideListRouter {
    func showRideInfo(with ride: RideViewModel)
}

class BaseRideListRouter: Router, RideListRouter {
    func showRideInfo(with ride: RideViewModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "RideInfoViewController")
        controller.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
}
