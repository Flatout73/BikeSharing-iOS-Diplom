//
//  MapViewController.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import MapKit
import CoreLocation
import BikeSharingCore
import RxSwift
import RxCocoa

class MapViewController: UIViewController {
    
   // var bikeCoordinates = [CLLocationCoordinate2D(latitude: 55.659967, longitude: 37.225591),
     //                       CLLocationCoordinate2D(latitude: 50.65996, longitude: 39.22559)]
    
    @IBOutlet var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var viewModel: BikeMapViewModel!
    
    @IBOutlet var bikeInfoView: BikeInfoView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.items.subscribe(onNext: { bikes in
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            self.mapView.addAnnotations(bikes.map {
                BikeAnnotation(bike: $0)
            })
        })
        
        mapView.delegate = self
        
        checkLocationAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        bikeInfoView.scanButton.rx.tap.bind {
            guard let bike = self.bikeInfoView.bike else { return }
            self.viewModel.rentBike(bike)
        }.disposed(by: disposeBag)
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            break
        case .denied:
            break
        case .notDetermined:
            self.locationManager.requestAlwaysAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let location = mapView.userLocation.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? BikeAnnotation else { return nil }
   
        let identifier = "marker"
        var view: MKAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = #imageLiteral(resourceName: "BikeIcon.png")
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        bikeInfoView.isHidden = false
        bikeInfoView.bike = (view.annotation as? BikeAnnotation)?.bike
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let location = userLocation.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            //mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
