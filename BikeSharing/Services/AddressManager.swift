//
//  AddressManager.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 11/05/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import MapKit

class AddressManager {
    public static let shared = AddressManager()
    
    let geocoder = CLGeocoder()
    let locale = Locale(identifier: "ru")
    
    func address(for location: Point, completion: @escaping(String?)->()) {
        self.geocoder.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude), preferredLocale: self.locale) { placemarks, error in
            guard let placemark = placemarks?.first else {
                completion(nil)
                return
            }
            let address = "\(placemark.thoroughfare ?? ""), \(placemark.subThoroughfare ?? "")"
            DispatchQueue.main.async {
                completion(address)
            }
        }
    }
}
