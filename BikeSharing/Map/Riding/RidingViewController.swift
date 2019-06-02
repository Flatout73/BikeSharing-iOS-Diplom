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
import MBProgressHUD
import RxSwift

class RidingViewController: UIViewController {
    @IBOutlet var timeLabel: UILabel!
    
    var startTime = Date()
    let formatter = DateComponentsFormatter()
    
    var paymentInfo: PaymentModel!
    
    var timer: Timer?
    
    var coreDataManager: CoreDataManager! //injected
    var apiService: ApiService!
    var mapkitManager: MapKitManager!
    var bluetoothManager: BluetoothManager!
    
    @IBOutlet var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var locationList: [CLLocation] = []
    
    var endingRide: RideViewModel?
    
    let disposeBag = DisposeBag()
    
    var currentBikeLocation: Point?
    
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
        
        bluetoothManager.statusFromLock.asObservable().subscribe(onNext: { status in
            if status == "CLOSED" {
                self.close(self)
            } else if status.contains("@") {
                let words = status.split(separator: " ")
                guard let lat = Double(words[1]),
                    let lon = Double(words[2].substring(to: words[2].index(before: words[2].endIndex))) else {
                        return
                    }
                
                self.currentBikeLocation = Point(latitude: lat, longitude: lon)
            }
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        
        if let location = mapView.userLocation.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
        }
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
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 600, height: 500), true, 0)
        
        // draw original image into the context
        image.draw(at: CGPoint.zero)
        
        // get the context for CoreGraphics
        let context = UIGraphicsGetCurrentContext()
        
        // set stroking width and color of the context
        context!.setLineWidth(2.0)
        context!.setStrokeColor(UIColor.black.cgColor)
        
        #imageLiteral(resourceName: "BikeIcon.png").draw(at: snapshot.point(for: viewModel.startLocation.coordinate))
        #imageLiteral(resourceName: "BikeIcon.png").draw(at: snapshot.point(for: mapView.userLocation.location!.coordinate))
        
        // Here is the trick :
        // We use addLine() and move() to draw the line, this should be easy to understand.
        // The diificult part is that they both take CGPoint as parameters, and it would be way too complex for us to calculate by ourselves
        // Thus we use snapshot.point() to save the pain.
        if !coordinates.isEmpty {
            context!.move(to: snapshot.point(for: coordinates[0]))
            for i in 0..<coordinates.count {
                context!.addLine(to: snapshot.point(for: coordinates[i]))
                context!.move(to: snapshot.point(for: coordinates[i]))
            }
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
     //   let location = CLLocationCoordinate2DMake(37.332077, -122.02962) // Apple HQ
//        let region = MKCoordinateRegion(MKMapRect(origin: MKMapPoint(CLLocationCoordinate2D(latitude: viewModel.startLocation.latitude, longitude: viewModel.startLocation.longitude)), size: MKMapSize(width: <#T##Double#>, height: <#T##Double#>)))
        
        var r = MKMapRect.null
        for coordinates in [viewModel.startLocation, viewModel.endLocation!] {
            let mapPoint = MKMapPoint(CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude))
            r = r.union(MKMapRect(x: mapPoint.x - 25000, y: mapPoint.y - 25000, width: 50000, height: 75000))
        }
        let region = MKCoordinateRegion(r)
        mapSnapshotOptions.region = region
        
        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
        mapSnapshotOptions.scale = UIScreen.main.scale
        
        // Set the size of the image output.
        mapSnapshotOptions.size = CGSize(width: 600, height: 500)
        
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var endRide = paymentInfo.ride
        // endRide.endTime = Date()
        endRide.endLocation = mapView.userLocation.location!.coordinate.point
        endRide.locations = locationList.map({ Point(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) })
        
        if let bikeLoc = currentBikeLocation {
            endRide.bike?.location = bikeLoc
        }
        
        if let endingRide = endingRide {
            guard let controller = storyboard.instantiateViewController(withIdentifier: "RideInfoViewController") as? RideInfoViewController else { return }
            controller.ride = endingRide
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            makeSnapshot(for: endRide) { image in
                self.mapkitManager.address(for: endRide.endLocation!) { address in
                    endRide.endAddress = address
                    self.apiService.endRide(endRide, with: image) { result in
                        switch result {
                        case .success(let ride):
                            self.coreDataManager.saveOneRide(by: ride)
                            
                            self.apiService.payRequest(token: self.paymentInfo.token, ride: ride) { response in
                                switch response {
                                case .success(let transaction):
                                    MBProgressHUD.hide(for: self.view, animated: true)
                                    
                                    self.timer?.invalidate()
                                    self.endingRide = ride
                                    guard let controller = storyboard.instantiateViewController(withIdentifier: "RideInfoViewController") as? RideInfoViewController else { return }
                                    controller.ride = ride
                                    self.navigationController?.pushViewController(controller, animated: true)
                                    
                                case .failure(let error):
                                    MBProgressHUD.hide(for: self.view, animated: true)
                                    NotificationBanner.showErrorBanner(error.localizedDescription)
                                }
                            }
                        case .failure(let error):
                            MBProgressHUD.hide(for: self.view, animated: true)
                            NotificationBanner.showErrorBanner(error.localizedDescription)
                        }
                    }
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
