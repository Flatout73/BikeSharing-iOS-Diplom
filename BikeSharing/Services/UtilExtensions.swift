//
//  UtilExtensions.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 13/05/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import MapKit

public let ShortDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .short
    dateFormatter.dateStyle = .short
    
    return dateFormatter
}()

public let ComponentsFormatter: DateComponentsFormatter = {
    let components = DateComponentsFormatter()
    components.allowedUnits = [.hour, .minute, .second]
    components.unitsStyle = .short
    
    return components
}()

extension CLLocationCoordinate2D {
    var point: Point {
        return Point(latitude: self.latitude, longitude: self.longitude)
    }
}

extension Point {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
