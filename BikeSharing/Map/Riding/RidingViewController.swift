//
//  RidingViewController.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 29/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RidingViewController: UIViewController {
    @IBOutlet var timeLabel: UILabel!
    
    var startTime = Date()
    let formatter = DateComponentsFormatter()
    
    var paymentInfo: PaymentModel!
    
    var timer: Timer?
    
    var coreDataManager: CoreDataManager! //injected
    var apiService: ApiService!
    
    @IBOutlet var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var locationList: [CLLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        startTime = Date()
        
        formatter.allowedUnits = [.hour, .minute, .second]
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    @objc func fireTimer() {
        timeLabel.text = formatter.string(from: Date().timeIntervalSince(startTime))
    }
    
    func drawLineOnImage(snapshot: MKMapSnapshotter.Snapshot, for viewModel: RideViewModel) -> UIImage {
        let image = snapshot.image
        
        guard let locations = viewModel.locations else {
            return image
        }
        
        let coordinates = locations.compactMap { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        // for Retina screen
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 400, height: 400), true, 0)
        
        // draw original image into the context
        image.draw(at: CGPoint.zero)
        
        // get the context for CoreGraphics
        let context = UIGraphicsGetCurrentContext()
        
        // set stroking width and color of the context
        context!.setLineWidth(2.0)
        context!.setStrokeColor(UIColor.black.cgColor)
        
        #imageLiteral(resourceName: "BikeIcon.png").draw(at: snapshot.point(for: coordinates[0]))
        #imageLiteral(resourceName: "BikeIcon.png").draw(at: snapshot.point(for: coordinates.last!))
        
        // Here is the trick :
        // We use addLine() and move() to draw the line, this should be easy to understand.
        // The diificult part is that they both take CGPoint as parameters, and it would be way too complex for us to calculate by ourselves
        // Thus we use snapshot.point() to save the pain.
        context!.move(to: snapshot.point(for: coordinates[0]))
        for i in 0..<coordinates.count {
            context!.addLine(to: snapshot.point(for: coordinates[i]))
            context!.move(to: snapshot.point(for: coordinates[i]))
        }
        
        // apply the stroke to the context
        context!.strokePath()
        
        // get the image from the graphics context
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end the graphics context
        UIGraphicsEndImageContext()
        
        return resultImage!
    }
    
    func makeSnapshot(for viewModel: RideViewModel, completion: @escaping (UIImage)->Void) {
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        
        // Set the region of the map that is rendered.
        let location = CLLocationCoordinate2DMake(37.332077, -122.02962) // Apple HQ
//        let region = MKCoordinateRegion(MKMapRect(origin: MKMapPoint(CLLocationCoordinate2D(latitude: viewModel.startLocation.latitude, longitude: viewModel.startLocation.longitude)), size: MKMapSize(width: <#T##Double#>, height: <#T##Double#>)))
        
        var r = MKMapRect.null
        for coordinates in [viewModel.startLocation, Point(latitude: location.latitude, longitude: location.longitude)] {
            let mapPoint = MKMapPoint(CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude))
            r = r.union(MKMapRect(x: mapPoint.x, y: mapPoint.y, width: 1, height: 1))
        }
        let region = MKCoordinateRegion(r)
        mapSnapshotOptions.region = region
        
        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
        mapSnapshotOptions.scale = UIScreen.main.scale
        
        // Set the size of the image output.
        mapSnapshotOptions.size = CGSize(width: 400, height: 400)
        
        // Show buildings and Points of Interest on the snapshot
        mapSnapshotOptions.showsBuildings = true
        
        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        snapShotter.start { snapshot, error in
            guard let snapshot = snapshot else {
                return
            }
            
            let image = self.drawLineOnImage(snapshot: snapshot, for: viewModel)
            completion(image)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        var endRide = paymentInfo.ride
        // endRide.endTime = Date()
        endRide.endLocation = Point(latitude: 40, longitude: 45)
        endRide.locations = locationList.map({ Point(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) })
        
        makeSnapshot(for: endRide) { image in
            self.apiService.endRide(endRide, with: image) { result in
                switch result {
                case .success(let ride):
                    self.coreDataManager.saveOneRide(by: ride)
                    self.apiService.payRequest(token: self.paymentInfo.token, amount: ride.cost ?? 50.0) { error in
                        if let error = error {
                            NotificationBanner.showErrorBanner(error.localizedDescription)
                        } else {
                            self.timer?.invalidate()
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let controller = storyboard.instantiateViewController(withIdentifier: "RideInfoViewController")
                            //                let navigationItem = UINavigationItem(title: "Info")
                            //                navigationItem.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismiss))
                            //
                            //                let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
                            //                navigationBar.setItems([navigationItem], animated: false)
                            //                controller.view.addSubview(navigationBar)
                            
                            //                (controller as? RideInfoViewController)?.completionHandler = {
                            //                    self.dismiss(animated: false, completion: nil)
                            //                }
                            
                            self.navigationController?.pushViewController(controller, animated: true)
                            //self.present(controller, animated: true, completion: nil)
                        }
                    }
                case .failure(let error):
                    NotificationBanner.showErrorBanner(error.localizedDescription)
                }
            }
        }
    }
}

extension RidingViewController: CLLocationManagerDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let location = userLocation.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            //if let lastLocation = locationList.last {
                //let delta = newLocation.distance(from: lastLocation)
                //distance = distance + Measurement(value: delta, unit: UnitLength.meters)
           // }
            
            locationList.append(newLocation)
        }
    }
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        checkLocationAuthorization()
//    }
}
