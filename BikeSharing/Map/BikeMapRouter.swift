//
//  BikeMapRouter.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 28/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import BikeSharingCore

protocol BikeMapRouter {
    
}

class BaseBikeMapRouter: Router, BikeMapRouter {
    func scanQR() {
        self.viewController?.performSegue(withIdentifier: "showScanner", sender: nil)
    }
}
