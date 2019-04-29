//
//  BikeAnnotation.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import MapKit

class BikeAnnotation: MKPointAnnotation {
    let locationName: String
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.locationName = locationName
        super.init()

        self.title = title
        self.coordinate = coordinate
    }
}
