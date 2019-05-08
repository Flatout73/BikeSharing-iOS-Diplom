//
//  BikeAnnotation.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import MapKit

class BikeAnnotation: MKPointAnnotation {
    let bike: BikeViewModel
    
    init(bike: BikeViewModel) {
        self.bike = bike
        super.init()
        
        self.title = String(bike.id)
        self.coordinate = CLLocationCoordinate2D(latitude: bike.location.latitude, longitude: bike.location.longitude)
    }
}
