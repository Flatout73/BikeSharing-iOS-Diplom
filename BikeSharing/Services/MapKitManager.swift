//
//  AddressManager.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 11/05/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import MapKit

class MapKitManager {
    
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
    
    func calculateRoute(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, completion: @escaping (MKRoute?)->Void) {
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { response, error in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            completion(response.routes.first)
        }
    }
}
