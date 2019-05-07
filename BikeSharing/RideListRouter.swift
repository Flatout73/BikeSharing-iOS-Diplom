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
        guard let controller = viewController?.storyboard?.instantiateViewController(withIdentifier: "RideInfoViewController") else { return }
        controller.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
}
