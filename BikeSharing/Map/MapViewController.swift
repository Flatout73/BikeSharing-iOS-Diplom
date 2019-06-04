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
        }, onError: { error in
            NotificationBanner.showErrorBanner(error.localizedDescription)
        })
        
        mapView.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        }
        
        bikeInfoView.scanButton.rx.tap.bind {
            guard let bike = self.bikeInfoView.bike else { return }
            self.viewModel.rentBike(bike)
        }.disposed(by: disposeBag)
        
        bikeInfoView.routeButton.rx.tap.bind {
            guard let bike = self.bikeInfoView.bike,
                    let sourceLocation = self.mapView.userLocation.location?.coordinate
                else { return }
            
            if !self.bikeInfoView.occupied {
                self.viewModel.calculateRoute(sourceLocation: sourceLocation, destinationLocation: bike.location.coordinate) { route in
                    guard let route = route else {
                        NotificationBanner.showErrorBanner("Не удалось построить маршрут")
                        return
                    }
                    self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
                    
                    let rect = route.polyline.boundingMapRect
                    self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
                }
                
                self.viewModel.bookBike(bike, occupied: true).subscribeOn(MainScheduler.instance).subscribe(onNext: { string in
                    NotificationBanner.showSuccessBanner("Велосипед успешно забронирован")
                    self.bikeInfoView.occupied = true
                    
                }, onError: { error in
                    NotificationBanner.showErrorBanner(error.localizedDescription)
                })
            } else {
                self.mapView.removeOverlays(self.mapView.overlays)
                
                self.viewModel.bookBike(bike, occupied: false).subscribe(onNext: { string in
                    NotificationBanner.showSuccessBanner("Бронирование отменено")
                    self.bikeInfoView.occupied = false
                }, onError: { error in
                    NotificationBanner.showErrorBanner(error.localizedDescription)
                })
            }
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
    
    var regionWasChanged = false
    func changeMapRegion() {
        if !regionWasChanged, let location = mapView.userLocation.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            regionWasChanged = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLocationAuthorization()
        changeMapRegion()
        
        AnalyticsHelper.event(name: "show_map")
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
        guard let bike = (view.annotation as? BikeAnnotation)?.bike, !bikeInfoView.occupied else {
            return
        }
        
        bikeInfoView.show(for: bike, mapkitManager: viewModel.mapkitManager)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        changeMapRegion()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
