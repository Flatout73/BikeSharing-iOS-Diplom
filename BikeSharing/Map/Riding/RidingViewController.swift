//
//  RidingViewController.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 29/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import UIKit
import MapKit

class RidingViewController: UIViewController {
    @IBOutlet var timeLabel: UILabel!
    
    var startTime = Date()
    let formatter = DateComponentsFormatter()
    
    var paymentInfo: PaymentModel!
    
    var timer: Timer?
    
    var coreDataManager: CoreDataManager! //injected
    var apiService: ApiService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        startTime = Date()
        
        formatter.allowedUnits = [.hour, .minute, .second]
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
    @IBAction func close(_ sender: Any) {
        var endRide = paymentInfo.ride
       // endRide.endTime = Date()
        endRide.endLocation = Point(latitude: 40, longitude: 45)
        apiService.endRide(endRide) { result in
            switch result {
            case .success(let ride):
                self.coreDataManager.saveOrCreateRide(by: ride)
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
